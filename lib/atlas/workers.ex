defmodule Atlas.Workers do
  @moduledoc """
  The Workers context for managing background jobs.
  """
  use Atlas.Context

  def list_jobs do
    Oban.Job
    |> where(fragment("meta ->> 'user_id' IS NOT NULL"))
    |> select_job_fields()
    |> Repo.all()
  end

  def list_user_jobs(user) do
    Oban.Job
    |> where(fragment("meta ->> 'user_id' = ?", ^to_string(user.id)))
    |> select_job_fields()
    |> Repo.all()
  end

  def get_job(id) do
    Oban.Job
    |> where(id: ^id)
    |> where(fragment("meta ->> 'user_id' IS NOT NULL"))
    |> select_job_fields()
    |> Repo.one()
  end

  defp select_job_fields(query) do
    query
    |> select([j], %{
      id: j.id,
      state: j.state,
      attempted_at: j.attempted_at,
      completed_at: j.completed_at,
      inserted_at: j.inserted_at,
      type: fragment("meta ->> 'type'"),
      user_id: fragment("meta ->> 'user_id'")
    })
  end
end
