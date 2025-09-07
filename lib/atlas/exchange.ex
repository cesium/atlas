defmodule Atlas.Exchange do
  @moduledoc """
  The Exchange context.
  """

  use Atlas.Context

  alias Atlas.Exchange.ShiftExchangeRequest
  alias Atlas.University
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
  Creates a shift_exchange_request.

  ## Examples

      iex> create_shift_exchange_request(%{field: value})
      {:ok, %ShiftExchangeRequest{}}

      iex> create_shift_exchange_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_exchange_request(attrs \\ %{}) do
    if University.student_enrolled_in_shift?(attrs["student_id"], attrs["shift_from"]) do
      %ShiftExchangeRequest{}
      |> ShiftExchangeRequest.changeset(attrs)
      |> Repo.insert()
    else
      {:error,
       Ecto.Changeset.change(%ShiftExchangeRequest{})
       |> Ecto.Changeset.add_error(:shift_from, "Student is not enrolled in the origin shift")}
    end
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

  def solve_exchanges do
    pending_requests =
      list_shift_exchange_requests(where: [status: :pending])
      |> Enum.sort_by(&priority/1, :desc)

    graph = build_graph(pending_requests)
    cycles = Graph.cycles(graph)

    cycles
    |> Enum.sort_by(&cycle_priority(&1, graph), :desc)
    |> Enum.each(&fulfill_cycle(&1, graph))
  end

  defp priority(%ShiftExchangeRequest{inserted_at: inserted_at}) do
    DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
  end

  defp cycle_priority(cycle, graph) do
    cycle
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [from, to] -> Graph.edge(graph, from, to).label end)
    |> Enum.map(&priority/1)
    |> Enum.sum()
  end

  defp build_graph(requests) do
    Enum.reduce(requests, Graph.new(type: :directed), fn req, g ->
      Graph.add_edge(g, req.shift_from_id, req.shift_to_id, label: req)
    end)
  end

  defp fulfill_cycle(cycle, graph) do
    requests =
      cycle
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [from, to] -> Graph.edge(graph, from, to).label end)

    Repo.transaction(fn ->
      Enum.each(requests, fn req ->
        # Update request → approved
        update_shift_exchange_request(req, %{status: :approved})

        # TODO: Update student shifts enrollments
      end)
    end)
  end
end
