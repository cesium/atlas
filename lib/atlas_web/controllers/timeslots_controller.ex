defmodule AtlasWeb.TimeslotsController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses.Shifts.Timeslot
  alias Atlas.University.Degrees.Courses.Timeslots

  def delete(conn, %{"id" => id}) do
    timeslot = Timeslots.get_timeslot!(id)

    with {:ok, %Timeslot{}} <- Timeslots.delete_timeslot(timeslot) do
      send_resp(conn, :no_content, "")
    end
  end
end
