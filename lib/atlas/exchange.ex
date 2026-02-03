defmodule Atlas.Exchange do
  @moduledoc """
  The Exchange context.
  """

  use Atlas.Context

  alias Atlas.Accounts.UserNotifier
  alias Atlas.Exchange.ShiftExchangeRequest
  alias Atlas.{Constants, University, Workers}
  alias Atlas.University.Degrees.Courses.Shifts
  alias Atlas.University.ShiftEnrollment
  alias Ecto.Multi
  alias Graph

  @doc """
  Returns the list of shift_exchange_requests.

  ## Examples

      iex> list_shift_exchange_requests()
      [%ShiftExchangeRequest{}, ...]

  """
  def list_shift_exchange_requests(opts \\ []) do
    ShiftExchangeRequest
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Returns the list of unique pending shift exchange requests.

  ## Examples

      iex> list_unique_pending_shift_exchange_requests()
      [%ShiftExchangeRequest{}, ...]

  """
  def list_unique_pending_shift_exchange_requests(opts \\ []) do
    ShiftExchangeRequest
    |> apply_filters(opts)
    |> where([r], r.status == :pending)
    |> distinct([r], [r.shift_from, r.shift_to])
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of pending shift exchange requests.

  ## Examples

      iex> list_pending_shift_exchange_requests()
      [%ShiftExchangeRequest{}, ...]

  """
  def list_pending_shift_exchange_requests(opts \\ []) do
    ShiftExchangeRequest
    |> apply_filters(opts)
    |> where([r], r.status == :pending)
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single shift_exchange_request.

  Raises `Ecto.NoResultsError` if the Shift exchange request does not exist.

  ## Examples

      iex> get_shift_exchange_request!(123)
      %ShiftExchangeRequest{}

      iex> get_shift_exchange_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift_exchange_request!(id), do: Repo.get!(ShiftExchangeRequest, id)

  @doc """
  Creates a shift_exchange_request and enqueues a job to try to solve all.

  ## Examples

      iex> create_shift_exchange_request(%{field: value})
      {:ok, %ShiftExchangeRequest{}}

      iex> create_shift_exchange_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_exchange_request(attrs \\ %{}) do
    if University.student_enrolled_in_shift?(attrs["student_id"], attrs["shift_from"]) do
      %ShiftExchangeRequest{}
      |> ShiftExchangeRequest.create_request_changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, request} ->
          enqueue_shift_exchange_solver_job()
          {:ok, request}

        {:error, changeset} ->
          {:error, changeset}
      end
    else
      {:error,
       Ecto.Changeset.change(%ShiftExchangeRequest{})
       |> Ecto.Changeset.add_error(:shift_from, "Student is not enrolled in the origin shift")}
    end
  end

  defp enqueue_shift_exchange_solver_job do
    # Enqueue job to try to solve exchanges
    Oban.insert(Workers.ShiftExchange.new(%{}))
  end

  @doc """
  Updates a shift_exchange_request.

  ## Examples

      iex> update_shift_exchange_request(shift_exchange_request, %{field: new_value})
      {:ok, %ShiftExchangeRequest{}}

      iex> update_shift_exchange_request(shift_exchange_request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift_exchange_request(%ShiftExchangeRequest{} = shift_exchange_request, attrs) do
    shift_exchange_request
    |> ShiftExchangeRequest.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift_exchange_request.

  ## Examples

      iex> delete_shift_exchange_request(shift_exchange_request)
      {:ok, %ShiftExchangeRequest{}}

      iex> delete_shift_exchange_request(shift_exchange_request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift_exchange_request(%ShiftExchangeRequest{} = shift_exchange_request) do
    Repo.delete(shift_exchange_request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift_exchange_request changes.

  ## Examples

      iex> change_shift_exchange_request(shift_exchange_request)
      %Ecto.Changeset{data: %ShiftExchangeRequest{}}

  """
  def change_shift_exchange_request(
        %ShiftExchangeRequest{} = shift_exchange_request,
        attrs \\ %{}
      ) do
    ShiftExchangeRequest.changeset(shift_exchange_request, attrs)
  end

  @doc """
  Checks if the current time is within the exchange period.
  """
  def exchange_period_active? do
    case get_exchange_period() do
      nil ->
        false

      %{start: start_str, end: end_str} ->
        with {:ok, start_time, _} <- DateTime.from_iso8601(start_str),
             {:ok, end_time, _} <- DateTime.from_iso8601(end_str) do
          now = DateTime.utc_now()
          DateTime.compare(now, start_time) != :lt and DateTime.compare(now, end_time) != :gt
        else
          _ -> false
        end
    end
  end

  @doc """
  Sets the interval during which shift exchange requests can be created.

  ## Examples

      iex> set_exchange_period(~U[2024-09-01 00:00:00Z], ~U[2024-09-30 23:59:59Z])
      :ok

      iex> set_exchange_period(~U[2024-10-01 00:00:00Z], ~U[2024-09-30 23:59:59Z])
      {:error, :invalid_interval}

  """
  def set_exchange_period(start_time, end_time) do
    if DateTime.compare(start_time, end_time) != :lt do
      {:error, "Start time must be before end time"}
    else
      Constants.set("exchange_period_start", start_time)
      Constants.set("exchange_period_end", end_time)
    end
  end

  @doc """
  Gets the current shift exchange period.
  """
  def get_exchange_period do
    start_time =
      case Constants.get("exchange_period_start") do
        {:ok, time} -> time
        _ -> nil
      end

    end_time =
      case Constants.get("exchange_period_end") do
        {:ok, time} -> time
        _ -> nil
      end

    case {start_time, end_time} do
      {nil, nil} -> nil
      _ -> %{start: start_time, end: end_time}
    end
  end

  @doc """
  Deletes the current shift exchange period.
  """
  def delete_exchange_period do
    Constants.set("exchange_period_start", nil)
    Constants.set("exchange_period_end", nil)
  end

  defp student_has_shift(student_id, shift_id) do
    Repo.exists?(
      from(se in ShiftEnrollment,
        where:
          se.student_id == ^student_id and se.shift_id == ^shift_id and
            se.status in [:active, :inactive]
      )
    )
  end

  @doc """
  Attempts to solve pending shift exchange requests by finding cycles in the exchange graph and approving them.
  """
  def solve_exchanges(opts \\ []) do
    # Get ALL pending requests where student is in their source shift
    all_pending =
      list_pending_shift_exchange_requests(opts)
      |> Enum.filter(fn req -> student_has_shift(req.student_id, req.shift_from) end)

    # Build graph with unique edges (one edge per shift pair)
    unique_by_shift_pair =
      all_pending
      |> Enum.uniq_by(fn req -> {req.shift_from, req.shift_to} end)

    graph = build_graph(unique_by_shift_pair)
    cycles = find_cycles(graph)

    # Track students already used across all cycles
    {all_approved_requests, _} =
      Enum.reduce(cycles, {[], MapSet.new()}, fn cycle, {acc_requests, used_students} ->
        cycle_set = MapSet.new(cycle)

        # Get shift pairs in this cycle
        shift_pairs =
          graph
          |> Graph.edges()
          |> Enum.filter(fn e -> e.v1 in cycle_set and e.v2 in cycle_set end)
          |> Enum.map(fn e -> {e.v1, e.v2} end)

        # Get ALL available requests for each shift pair (excluding used students)
        requests_by_pair =
          shift_pairs
          |> Enum.map(fn pair ->
            requests =
              all_pending
              |> Enum.filter(fn req ->
                {req.shift_from, req.shift_to} == pair and req.student_id not in used_students
              end)
            {pair, requests}
          end)
          |> Enum.into(%{})

        # Determine how many complete cycles we can form
        # Limited by the shift pair with fewest available students
        max_cycles =
          requests_by_pair
          |> Map.values()
          |> Enum.map(&length/1)
          |> Enum.min(fn -> 0 end)

        if max_cycles > 0 do
          # Select max_cycles students per shift pair
          selected_requests =
            requests_by_pair
            |> Enum.flat_map(fn {_pair, requests} ->
              Enum.take(requests, max_cycles)
            end)

          new_used_students =
            selected_requests
            |> Enum.map(& &1.student_id)
            |> MapSet.new()
            |> MapSet.union(used_students)

          {[selected_requests | acc_requests], new_used_students}
        else
          {acc_requests, used_students}
        end
      end)

    # Approve all requests in a single transaction
    case approve_all_requests(Enum.concat(all_approved_requests)) do
      {:ok, approved_count} ->
        %{cycles_found: length(cycles), requests_approved: approved_count}

      {:error, _reason} ->
        %{cycles_found: length(cycles), requests_approved: 0}
    end
  end

  def maybe_auto_approve_pending_requests(opts \\ []) do
    pending_requests = list_pending_shift_exchange_requests(opts) |> Enum.filter(fn req ->
      student_has_shift(req.student_id, req.shift_from)
    end)

    Enum.each(pending_requests, fn req ->
      case Repo.transaction(maybe_auto_approve_request(req)) do
        {:ok, _changes} ->
          # Reload student and shift for notification email
          user = University.get_student!(req.student_id, preloads: [:user]).user
          shift_to = Shifts.get_shift!(req.shift_to, preloads: [:course])

          UserNotifier.deliver_shift_exchange_request_fulfilled(
            user,
            shift_to.course.name,
            Shifts.Shift.short_name(shift_to)
          )

        {:error, :shift_has_space, :no_space, _} ->
          # Couldn't auto approve → do nothing
          :ok

        {:error, _step, _reason, _changes} ->
          :ok
      end
    end)
  end

  ## Graph-related utility functions

  defp build_graph(requests) do
    Enum.reduce(requests, Graph.new(type: :directed), fn req, g ->
      Graph.add_edge(g, req.shift_from, req.shift_to, label: req)
    end)
  end

  defp find_cycles(g) do
    g
    |> Graph.strong_components()
    |> Enum.filter(&(length(&1) >= 2))
    |> Enum.flat_map(&find_cycles_in_component(g, &1))
    |> uniq_cycles()
  end

  defp find_cycles_in_component(g, vertices) do
    sub = Graph.subgraph(g, vertices)

    vertices
    |> Enum.flat_map(fn start ->
      dfs_cycles(sub, start, start, [start], MapSet.new([start]))
    end)
  end

  defp dfs_cycles(g, start, current, path, visited) do
    Graph.out_neighbors(g, current)
    |> Enum.flat_map(fn next ->
      cond do
        next == start and length(path) >= 2 ->
          # Found cycle
          [Enum.reverse(path)]

        MapSet.member?(visited, next) ->
          # Ignore back edges to already visited vertex (other than start)
          []

        true ->
          dfs_cycles(g, start, next, [next | path], MapSet.put(visited, next))
      end
    end)
  end

  defp uniq_cycles(cycles) do
    cycles
    |> Enum.map(&canonical_cycle/1)
    |> MapSet.new()
    |> Enum.map(& &1)
  end

  defp canonical_cycle(cycle) do
    rotations = rotations(cycle)
    best_forward = Enum.min_by(rotations, & &1)
    best_backward = Enum.min_by(rotations(Enum.reverse(cycle)), & &1)
    if best_forward <= best_backward, do: best_forward, else: best_backward
  end

  defp rotations(list) do
    for i <- 0..(length(list) - 1) do
      {head, tail} = Enum.split(list, i)
      tail ++ head
    end
  end

  defp approve_cycle(g, cycle_vertices) do
    cycle_set = MapSet.new(cycle_vertices)

    # Get all requests whose edges are inside the cycle
    requests =
      g
      |> Graph.edges()
      |> Enum.filter(fn e -> e.v1 in cycle_set and e.v2 in cycle_set end)
      |> Enum.map(& &1.label)
      |> Enum.filter(&match?(%ShiftExchangeRequest{}, &1))

    approve_all_requests(requests)
  end

  defp approve_all_requests([]), do: {:ok, 0}

  defp approve_all_requests(requests) do
    multi =
      Enum.reduce(requests, Multi.new(), fn %ShiftExchangeRequest{} = req, m ->
        # Update the request status to approved
        m =
          Multi.update(
            m,
            {:approve_request, req.id},
            Ecto.Changeset.change(req, status: :approved)
          )

        # Delete the student’s enrollment in the origin shift
        m =
          Multi.delete_all(
            m,
            {:delete_from_enrollment, req.id},
            from(se in ShiftEnrollment,
              where: se.student_id == ^req.student_id and se.shift_id == ^req.shift_from
            )
          )

        # Delete student override for the destination shift (in case it exists)
        m =
          Multi.delete_all(
            m,
            {:delete_from_enrollment_override, req.id},
            from(se in ShiftEnrollment,
              where:
                se.student_id == ^req.student_id and se.shift_id == ^req.shift_to and
                  se.status == :override
            )
          )

        # Create a new enrollment for the student in the destination shift
        new_enrollment_changeset =
          %ShiftEnrollment{}
          |> ShiftEnrollment.changeset(%{
            student_id: req.student_id,
            shift_id: req.shift_to,
            status: :active
          })

        Multi.insert(m, {:insert_to_enrollment, req.id}, new_enrollment_changeset)
      end)

    case Repo.transaction(multi) do
      {:ok, _changes} ->
        # Send notification emails - one per student to avoid spam
        requests
        |> Enum.uniq_by(& &1.student_id)
        |> Enum.each(fn req ->
          user = University.get_student!(req.student_id, preloads: [:user]).user
          shift_to = Shifts.get_shift!(req.shift_to, preloads: [:course])

          UserNotifier.deliver_shift_exchange_request_fulfilled(
            user,
            shift_to.course.name,
            Shifts.Shift.short_name(shift_to)
          )
        end)

        {:ok, length(requests)}

      {:error, _op, _changeset, _sofar} ->
        {:error, :transaction_failed}
    end
  end

  defp maybe_auto_approve_request(%ShiftExchangeRequest{} = req) do
    Multi.new()
    |> Multi.run(:shift_has_space, fn _repo, _changes ->
      enrolled_count =
        Repo.one(
          from(se in ShiftEnrollment,
            where: se.shift_id == ^req.shift_to and se.status in [:active, :inactive],
            select: count(se.student_id, :distinct)
          )
        )

      shift = Shifts.get_shift!(req.shift_to)
      from_shift = Shifts.get_shift!(req.shift_from)
      from_shift_occupation = University.get_shift_enrollment_count(req.shift_from)

      cond do
        from_shift_occupation - 1 <= round(from_shift.capacity * 0.8) ->
          {:error, :shift_from_underoccupied}

        enrolled_count < shift.capacity ->
          {:ok, :has_space}

        true ->
          {:error, :no_space}
      end
    end)
    |> Multi.update(
      :approve_request,
      Ecto.Changeset.change(req, status: :approved)
    )
    |> Multi.delete_all(
      :delete_from_enrollment,
      from(se in ShiftEnrollment,
        where: se.student_id == ^req.student_id and se.shift_id == ^req.shift_from
      )
    )
    |> Multi.insert(
      :insert_to_enrollment,
      ShiftEnrollment.changeset(%ShiftEnrollment{}, %{
        student_id: req.student_id,
        shift_id: req.shift_to,
        status: :active
      })
    )
  end
end
