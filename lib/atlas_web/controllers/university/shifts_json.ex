defmodule AtlasWeb.ShiftsJSON do
  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias AtlasWeb.University.TimeslotJSON

  def index(%{shifts: shifts}) do
    %{data: for(shift <- shifts, do: data(shift))}
  end

  def show(%{shift: shift}) do
    %{data: data(shift)}
  end

  def data(%Shift{} = shift) do
    %{
      id: shift.id,
      number: shift.number,
      type: shift.type,
      professor: shift.professor,
      timeslots:
        if Ecto.assoc_loaded?(shift.timeslots) do
          for timeslot <- shift.timeslots, do: TimeslotJSON.data(timeslot)
        else
          []
        end,
      enrollment_status:
        if Ecto.assoc_loaded?(shift.enrollments) && shift.enrollments != [] do
          hd(shift.enrollments).status
        else
          nil
        end
    }
  end
end
