defmodule Atlas.University.Degrees.Courses.ShiftsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University.Degrees.Courses.Shifts` context.
  """

  @doc """
  Generate a shift.
  """
  def shift_fixture(attrs \\ %{}) do
    {:ok, shift} =
      attrs
      |> Enum.into(%{
        capacity: 42,
        number: 42,
        professor: "some professor",
        type: "some type"
      })
      |> Atlas.University.Degrees.Courses.Shifts.create_shift()

    shift
  end

  @doc """
  Generate a timeslot.
  """
  def timeslot_fixture(attrs \\ %{}) do
    {:ok, timeslot} =
      attrs
      |> Enum.into(%{
        building: "some building",
        end: ~T[14:00:00],
        room: "some room",
        start: ~T[14:00:00],
        weekday: "some weekday"
      })
      |> Atlas.University.Degrees.Courses.Shifts.create_timeslot()

    timeslot
  end
end
