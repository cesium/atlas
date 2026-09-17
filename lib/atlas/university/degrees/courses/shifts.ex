defmodule Atlas.University.Degrees.Courses.Shifts do
  @moduledoc """
  The Shifts context.
  """
  alias Atlas.University.Degrees.Courses.Course
  use Atlas.Context

  alias Atlas.University.Degrees.Courses.Shifts.Shift

  @doc """
  Returns the list of shifts.

  ## Examples

      iex> list_shifts()
      [%Shift{}, ...]

  """
  def list_shifts(opts \\ []) do
    Shift
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single shift.

  Raises `Ecto.NoResultsError` if the Shift does not exist.

  ## Examples

      iex> get_shift!(123)
      %Shift{}

      iex> get_shift!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift!(id, opts \\ []) do
    Shift
    |> apply_filters(opts)
    |> Repo.get!(id)
  end

  @doc """
  Creates a shift.

  ## Examples

      iex> create_shift(%{field: value})
      {:ok, %Shift{}}

      iex> create_shift(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift.

  ## Examples

      iex> update_shift(shift, %{field: new_value})
      {:ok, %Shift{}}

      iex> update_shift(shift, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift.

  ## Examples

      iex> delete_shift(shift)
      {:ok, %Shift{}}

      iex> delete_shift(shift)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift(%Shift{} = shift) do
    Repo.delete(shift)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift changes.

  ## Examples

      iex> change_shift(shift)
      %Ecto.Changeset{data: %Shift{}}

  """
  def change_shift(%Shift{} = shift, attrs \\ %{}) do
    Shift.changeset(shift, attrs)
  end

  def get_shift_by_course_type_number(course_id, type, number) do
    Repo.one(
      from s in Shift,
        where: s.course_id == ^course_id and s.type == ^type and s.number == ^number
    )
  end

  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

  @doc """
  Returns the list of timeslots.

  ## Examples

      iex> list_timeslots()
      [%Timeslot{}, ...]

  """
  def list_timeslots do
    Repo.all(Timeslot)
  end

  @doc """
  Gets a single timeslot.

  Raises `Ecto.NoResultsError` if the Timeslot does not exist.

  ## Examples

      iex> get_timeslot!(123)
      %Timeslot{}

      iex> get_timeslot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timeslot!(id), do: Repo.get!(Timeslot, id)

  @doc """
  Gets a single timeslot by scraped id.

  ## Examples

      iex> get_timeslot_by_scraped_id(123)
      %Timeslot{}

  """
  def get_timeslot_by_scraped_id(scraped_id) do
    Timeslot
    |> where([t], t.scraped_id == ^scraped_id)
    |> Repo.one()
  end

  @doc """
  Gets a single timeslot by natural key match.

  ## Examples

      iex> get_timeslot_by_natural_key("name", "PL", 2, ~T[09:00:00], ~T[10:00:00], :monday)
      %Timeslot{}

  """
  def get_timeslot_by_natural_key(
        course_name,
        shift_type,
        shift_number,
        start_time,
        end_time,
        weekday
      ) do
    Course
    |> join(:inner, [c], s in assoc(c, :shifts))
    |> join(:inner, [c, s], t in assoc(s, :timeslots))
    |> where(
      [c, s, t],
      c.name == ^course_name and
        s.type == ^shift_type and
        s.number == ^shift_number and
        t.start == ^start_time and
        t.end == ^end_time and
        t.weekday == ^weekday
    )
    |> select([c, s, t], t)
    |> Repo.one()
  end

  @doc """
  Creates a timeslot.

  ## Examples

      iex> create_timeslot(%{field: value})
      {:ok, %Timeslot{}}

      iex> create_timeslot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timeslot(attrs \\ %{}) do
    %Timeslot{}
    |> Timeslot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timeslot.

  ## Examples

      iex> update_timeslot(timeslot, %{field: new_value})
      {:ok, %Timeslot{}}

      iex> update_timeslot(timeslot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timeslot(%Timeslot{} = timeslot, attrs) do
    timeslot
    |> Timeslot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timeslot.

  ## Examples

      iex> delete_timeslot(timeslot)
      {:ok, %Timeslot{}}

      iex> delete_timeslot(timeslot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timeslot(%Timeslot{} = timeslot) do
    Repo.delete(timeslot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timeslot changes.

  ## Examples

      iex> change_timeslot(timeslot)
      %Ecto.Changeset{data: %Timeslot{}}

  """
  def change_timeslot(%Timeslot{} = timeslot, attrs \\ %{}) do
    Timeslot.changeset(timeslot, attrs)
  end
end
