defmodule Atlas.Workers.GenerateStudentsSchedule do
  @moduledoc """
  Worker to generate schedules for students.
  """
  use Oban.Worker, queue: :schedule_generator

  alias Atlas.University.Schedule

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job_id" => job_id}}) do
    poll_schedule_result(job_id)
    :ok
  end

  def poll_schedule_result(request_id, attempts \\ 0) do
    case Schedule.fetch_result(request_id) do
      {:ok, %{status: :completed}} ->
        {:ok, :completed}

      {:ok, %{status: :running}} when attempts < 2000 ->
        :timer.sleep(1000)
        poll_schedule_result(request_id, attempts + 1)

      {:ok, %{status: :running}} ->
        {:error, :timeout}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
