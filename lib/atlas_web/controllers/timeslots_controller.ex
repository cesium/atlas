defmodule AtlasWeb.TimeslotsController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses.Shifts
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

  def delete(conn, %{"id" => id}) do
    timeslot = Shifts.get_timeslot!(id)

    with {:ok, %Timeslot{}} <- Shifts.delete_timeslot(timeslot) do
      send_resp(conn, :no_content, "")
    end
  end
end
