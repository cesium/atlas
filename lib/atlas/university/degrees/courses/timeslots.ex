defmodule Atlas.University.Degrees.Courses.Timeslots do
  @moduledoc """
  The Timeslots context.
  """
  use Atlas.Context
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

  @doc """
  Gets a single timeslot.

  ## Examples

      iex> get_timeslot!(123)
      %Timeslot{}

      iex> get_timeslot!(456)
      ** (Ecto.NoResultsError)
  """
  def get_timeslot!(id, opts \\ []) do
    Timeslot
    |> apply_filters(opts)
    |> Repo.get!(id)
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
end
