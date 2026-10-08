defmodule Atlas.Statistics do
  @moduledoc """
  The Statistics context.
  """
  use Atlas.Context

  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias Atlas.University.ShiftEnrollment

  def course_shifts_capacity_occupation(course_id) do
    Shift
    |> where([s], s.course_id == ^course_id)
    |> join(:left, [s], e in ShiftEnrollment, on: e.shift_id == s.id)
    |> where([s, e], e.status != :override or is_nil(e.id))
    |> group_by([s], s.id)
    |> select([s, e], %{
      shift_id: s.id,
      type: s.type,
      number: s.number,
      capacity: s.capacity,
      occupation: count(e.id)
    })
    |> Repo.all()
  end
end
