defmodule AtlasWeb.University.ShiftJSON do
  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias AtlasWeb.University.TimeslotJSON

  def data(%Shift{} = shift) do
    %{
      id: shift.id,
      number: shift.number,
      type: shift.type,
      professor: shift.professor,
      timeslots: for(timeslot <- shift.timeslots, do: TimeslotJSON.data(timeslot))
    }
  end
end
