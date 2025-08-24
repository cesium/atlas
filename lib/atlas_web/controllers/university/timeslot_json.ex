defmodule AtlasWeb.University.TimeslotJSON do
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

  def data(%Timeslot{} = timeslot) do
    %{
      id: timeslot.id,
      start: String.slice(to_string(timeslot.start), 0..4),
      end: String.slice(to_string(timeslot.end), 0..4),
      weekday: timeslot.weekday,
      building: timeslot.building,
      room: timeslot.room
    }
  end
end
