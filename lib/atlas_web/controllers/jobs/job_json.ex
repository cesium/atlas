defmodule AtlasWeb.JobJSON do
  @moduledoc """
  A module for rendering job data in JSON format.
  """

  @doc """
  Renders a list of jobs as JSON.
  """
  def index(%{jobs: jobs}) do
    %{jobs: for(job <- jobs, do: data(job))}
  end

  @doc """
  Renders a single job as JSON.
  """
  def show(%{job: job}) do
    %{job: data(job)}
  end

  @doc """
  Renders a job as JSON.
  """
  def data(job) do
    %{
      id: job.id,
      state: job.state,
      attempted_at: job.attempted_at,
      completed_at: job.completed_at,
      inserted_at: job.inserted_at,
      type: job.type || "none",
      user_id: job.user_id
    }
  end
end
