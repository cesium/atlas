defmodule AtlasWeb.University.ScheduleController do
  use AtlasWeb, :controller

  def available_degrees(conn, _params) do
    degrees = Atlas.University.Degrees.list_degrees()

    conn
    |> put_view(AtlasWeb.University.DegreeeJSON)
    |> render(:index, degrees: degrees)
  end

  def generate_schedule(conn, %{"degree" => degree, "semester" => semester}) do
    case Atlas.University.Schedule.request_schedule_generation(%{
           degree: degree,
           semester: semester
         }) do
      {:ok, body} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Schedule generation started.", job_id: body["jobid"]})

      {:error, %Mint.TransportError{reason: :econnrefused}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Schedule generation service is unavailable."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not generate schedule: #{reason}."})
    end
  end
end
