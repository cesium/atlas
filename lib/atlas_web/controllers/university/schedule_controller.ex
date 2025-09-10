defmodule AtlasWeb.University.ScheduleController do
  use AtlasWeb, :controller

  alias Atlas.University
  alias Atlas.University.Degrees
  alias Atlas.University.Degrees.Degree

  def available_degrees(conn, _params) do
    degrees = Degrees.list_degrees()

    conn
    |> put_view(AtlasWeb.University.DegreeeJSON)
    |> render(:index, degrees: degrees)
  end

  def generate_schedule(conn, %{"degree" => degree_id, "semester" => semester}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    with %Degree{} = degree <- Degrees.get_degree(degree_id),
         {:ok, semester} <- parse_semester(semester),
         {:ok, body} <-
           University.Schedule.request_schedule_generation(%{
             degree: degree.id,
             semester: semester
           }),
         {:ok, job} <- University.Schedule.queue_generate_schedule(body["jobid"], user) do
      conn
      |> json(%{job_id: job.id, message: "Import job queued successfully."})
    else
      {:error, :invalid_semester} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid semester. Please provide a valid semester (1 or 2)."})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Degree not found."})

      {:error, %Mint.TransportError{reason: :econnrefused}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Schedule generation service is unavailable."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not queue schedule generation: #{reason}."})
    end
  end

  def generate_schedule(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing required parameters: degree and semester."})
  end

  def build_schedule_generation_request(conn, %{"degree" => degree_id, "semester" => semester}) do
    with %Degree{} = degree <- Degrees.get_degree(degree_id),
         {:ok, semester} <- parse_semester(semester) do
      University.Schedule.build_schedule_request(%{
        degree: degree.id,
        semester: semester
      })
      |> case do
        nil ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{error: "Could not build schedule generation request."})

        body ->
          conn
          |> json(%{request: Jason.decode!(body)})
      end
    else
      {:error, :invalid_semester} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid semester. Please provide a valid semester (1 or 2)."})

      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Degree not found."})
    end
  end

  def import_schedule_result(conn, body) do
    case body do
      %{"schedules" => schedules} ->
        case University.Schedule.import_schedule_result(schedules) do
          {:ok, _result} ->
            conn
            |> json(%{message: "Schedule imported successfully."})

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Could not import schedule: #{inspect(reason)}."})
        end
    end
  end

  defp parse_semester(sem) when is_integer(sem) and sem in 1..2, do: {:ok, sem}
  defp parse_semester(_), do: {:error, :invalid_semester}
end
