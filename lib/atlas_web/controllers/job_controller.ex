defmodule AtlasWeb.JobController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  alias Atlas.Workers

  action_fallback AtlasWeb.FallbackController

  swagger_path :index do
    get("/v1/jobs")
    summary("List all jobs")
    description("Returns a list of all jobs in the system.")

    response(200, "Jobs successfully retrieved", Schema.ref(:JobsResponse))
    security([%{Bearer: []}])
  end

  def index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    jobs =
      if user_can_list_all_jobs?(user) do
        Workers.list_jobs()
      else
        Workers.list_user_jobs(user)
      end

    render(conn, :index, jobs: jobs)
  end

  swagger_path :show do
    get("/v1/jobs/{id}")
    summary("Get a job by ID")
    description("Returns details of a specific job.")

    parameters do
      id(:path, :string, "ID of the job", required: true)
    end

    response(200, "Job successfully retrieved", Schema.ref(:JobResponse))
    response(404, "Job not found")
    security([%{Bearer: []}])
  end

  def show(conn, %{"id" => id}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Workers.get_job(id) |> verify_access(user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Job not found"})

      job ->
        render(conn, :show, job: job)
    end
  end

  defp verify_access(nil, _), do: nil

  defp verify_access(job, user) do
    if user_can_list_all_jobs?(user) || job.user_id == user.id do
      job
    else
      nil
    end
  end

  defp user_can_list_all_jobs?(user) do
    user && user.type == :admin
  end

  def swagger_definitions do
    %{
      JobsResponse:
        swagger_schema do
          title("JobsResponse")
          description("Response containing a list of jobs")

          properties do
            jobs(:array, "List of jobs", items: Schema.ref(:Job))
          end
        end,
      JobResponse:
        swagger_schema do
          title("JobResponse")
          description("Response containing a single job")

          properties do
            job(Schema.ref(:Job), "Details of the job")
          end
        end,
      Job:
        swagger_schema do
          title("Job")
          description("A job in the system")

          properties do
            id(:integer, "ID of the job", required: true)
            type(:string, "Type of the job", required: true)
            state(:string, "Status of the job", required: true)
            user_id(:string, "ID of the user who created the job", required: true)

            inserted_at(:string, "Timestamp when the job was created",
              format: "date-time",
              required: true
            )

            attempted_at(:string, "Timestamp when the job was attempted",
              format: "date-time",
              required: true
            )

            completed_at(:string, "Timestamp when the job was completed",
              format: "date-time",
              required: true
            )
          end
        end
    }
  end
end
