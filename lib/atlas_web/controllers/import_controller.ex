defmodule AtlasWeb.ImportController do
  use AtlasWeb, :controller

  alias Atlas.University
  alias Plug.Upload

  action_fallback AtlasWeb.FallbackController

  def students_by_course(conn, %{"file" => %Upload{path: file_path}}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case University.queue_import_students_by_course(file_path, user) do
      {:ok, job} ->
        json(conn, %{job_id: job.id, message: "Import job queued successfully."})

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not start import."})
    end
  end
end
