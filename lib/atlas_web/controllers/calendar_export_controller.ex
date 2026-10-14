defmodule AtlasWeb.CalendarExportController do
  use AtlasWeb, :controller

  alias Atlas.Accounts.Guardian
  alias Atlas.Calendar
  alias Atlas.Events
  alias AtlasWeb.AuthController

  @audience "astra"

  @doc """
  Returns a short-lived signed URL to export the current user's events calendar.
  """
  def calendar_url(conn, _params) do
    {user, session} = Guardian.Plug.current_resource(conn)

    if is_nil(user) do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    else
      token =
        AuthController.generate_token(user, session, :calendar)

      base_url = Application.get_env(:atlas, :api_url)

      url = "#{base_url}/v1/export/student/calendar.ics?token=#{token}"

      conn
      |> json(%{calendar_url: url})
    end
  end

  @doc """
  Exports the current user's events as an `.ics` file, given a valid calendar token.
  """
  def student_calendar(conn, %{"token" => token}) do
    with {:ok, claims} <-
           Guardian.decode_and_verify(token, %{"typ" => "calendar", "aud" => @audience}),
         {:ok, {user, _session}} <- Guardian.resource_from_claims(claims) do
      events = Events.list_events_by_user(user.id)

      ics_content =
        Calendar.events_to_ics(events, calendar_name: "Student #{user.name} Events")

      conn
      |> put_resp_content_type("text/calendar; charset=utf-8")
      |> put_resp_header(
        "content-disposition",
        ~s[attachment; filename="student-#{user.name}-calendar.ics"]
      )
      |> send_resp(200, ics_content)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired calendar token"})
    end
  end
end
