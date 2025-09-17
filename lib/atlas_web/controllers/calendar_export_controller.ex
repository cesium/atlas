defmodule AtlasWeb.CalendarExportController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses.Shifts
  alias Atlas.Calendar

  @doc """
  Exports a student's full schedule as an `.ics` file.
  """
  def student_calendar(conn, %{"student_id" => student_id}) do
    shifts = Shifts.list_shifts_for_student(student_id)
    ics_content = Calendar.shifts_to_ics(shifts, calendar_name: "Student #{student_id} Schedule")

    conn
    |> put_resp_content_type("text/calendar; charset=utf-8")
    |> put_resp_header(
      "content-disposition",
      ~s[attachment; filename="student-#{student_id}-calendar.ics"]
    )
    |> send_resp(200, ics_content)
  end
end
