defmodule AtlasWeb.CourseController do
  use AtlasWeb, :controller

  alias Atlas.{Accounts, Degrees, University, Workers}
  alias Plug.Upload

  action_fallback AtlasWeb.FallbackController

  def import_course_data(conn, %{"file" => %Upload{path: file_path}}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Oban.insert(Workers.ImportStudentsByCourse.new(%{"file_path" => file_path}, meta: %{user_id: user.id})) do
      {:ok, _job} ->
        json(conn, %{message: "Import started. Processing in background."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not start import: #{inspect(reason)}"})
    end
  end
end
