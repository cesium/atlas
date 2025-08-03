defmodule AtlasWeb.ImportController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  alias Atlas.University
  alias Plug.Upload

  action_fallback AtlasWeb.FallbackController

  swagger_path :students_by_courses do
    post("/v1/import/students_by_courses")
    summary("Import students by courses")
    description("Uploads an Excel file to import students by courses.")
    consumes("multipart/form-data")

    parameters do
      file(:formData, :file, "Excel file containing students and courses", required: true)
    end

    response(200, "Import job queued successfully.", Schema.ref(:SuccessfulImport))
    response(500, "Internal server error.")
    security([%{Bearer: []}])
  end

  def students_by_courses(conn, %{"file" => %Upload{path: file_path}}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case University.queue_import_students_by_courses(file_path, user) do
      {:ok, job} ->
        json(conn, %{job_id: job.id, message: "Import job queued successfully."})

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not start import."})
    end
  end

  def swagger_definitions do
    %{
      SuccessfulImport:
        swagger_schema do
          title("SuccessfulImport")
          description("Response for a successful import")

          properties do
            job_id(:string, "ID of the import job", required: true)
            message(:string, "Status message", required: true)
          end
        end
    }
  end
end
