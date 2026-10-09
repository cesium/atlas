defmodule AtlasWeb.ScheduleExportController do
  use AtlasWeb, :controller

  alias Atlas.Accounts.Guardian
  alias Atlas.Calendar
  alias Atlas.University
  alias Atlas.University.Degrees.Courses.Shifts
  alias AtlasWeb.AuthController

  @audience "astra"

  @doc """
  Returns a short-lived signed URL to export the current student's class schedule.
  """
  def schedule_url(conn, _params) do
    {user, session} = Guardian.Plug.current_resource(conn)

    if is_nil(user) do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    else
      token =
        AuthController.generate_token(user, session, :schedule)

      base_url = Application.get_env(:atlas, :api_url)

      url = "#{base_url}/v1/export/student/schedule.ics?token=#{token}"

      conn
      |> json(%{schedule_url: url})
    end
  end

  @doc """
  Exports the current student's class schedule as an `.ics` file, given a valid schedule token.
  """
  def student_schedule(conn, %{"token" => token} = params) do
    with {:ok, claims} <-
           Guardian.decode_and_verify(token, %{"typ" => "schedule", "aud" => @audience}),
         {:ok, {user, _session}} <- Guardian.resource_from_claims(claims),
         student <- University.get_student_by_user_id(user.id),
         %{} = student <- student do
      statuses =
        if params["original_only"] == "true",
          do: [:active, :inactive],
          else: [:active, :override]

      shifts = Shifts.list_shifts_for_student(student.id, statuses: statuses)

      ics_content =
        Calendar.schedule_to_ics(shifts, calendar_name: "Student #{user.name} Schedule")

      conn
      |> put_resp_content_type("text/calendar; charset=utf-8")
      |> put_resp_header(
        "content-disposition",
        ~s[attachment; filename="student-#{user.name}-schedule.ics"]
      )
      |> send_resp(200, ics_content)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired schedule token"})
    end
  end
end
