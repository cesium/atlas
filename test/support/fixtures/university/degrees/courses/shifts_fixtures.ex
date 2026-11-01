defmodule Atlas.University.Degrees.Courses.ShiftsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University.Degrees.Courses.Shifts` context.
  """
  alias Atlas.DegreesFixtures
  alias Atlas.University.Degrees.Courses.Shifts

  @doc """
  Generate a shift.
  """
  def shift_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new(:capacity, 42)
      |> Map.put_new_lazy(:number, fn -> System.unique_integer([:positive]) end)
      |> Map.put_new(:professor, "some professor")
      |> Map.put_new(:type, :theoretical)
      |> Map.put_new_lazy(:course_id, fn -> DegreesFixtures.course_fixture().id end)

    {:ok, shift} = Shifts.create_shift(attrs)

    shift
  end

  @doc """
  Generate a timeslot.
  """
  def timeslot_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new(:building, "some building")
      |> Map.put_new(:end, ~T[14:00:00])
      |> Map.put_new(:room, "some room")
      |> Map.put_new(:start, ~T[14:00:00])
      |> Map.put_new(:weekday, :monday)
      |> Map.put_new_lazy(:shift_id, fn -> shift_fixture().id end)

    {:ok, timeslot} = Shifts.create_timeslot(attrs)

    timeslot
  end
end
