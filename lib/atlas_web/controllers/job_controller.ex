defmodule AtlasWeb.JobController do
  use AtlasWeb, :controller

  alias Atlas.Workers

  action_fallback AtlasWeb.FallbackController

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
end
