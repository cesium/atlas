defmodule Atlas.Workers.GenerateStudentsSchedule do
  @moduledoc """
  Worker to generate schedules for students.
  """
  use Oban.Worker, queue: :schedule_generator

  alias Atlas.University.Schedule

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"job_id" => job_id}}) do
    IO.inspect(job_id, label: "Starting schedule generation for job ID 2")
    poll_schedule_result(job_id)
  end

  def poll_schedule_result(request_id, attempts \\ 0) do
    IO.inspect(request_id, label: "Polling schedule result for request ID")

    case Schedule.fetch_result(request_id) do
      {:ok, %{status: :completed}} ->
        :ok

      {:ok, %{status: :running}} when attempts < 2000 ->
        Process.sleep(1000)
        poll_schedule_result(request_id, attempts + 1)

      {:ok, %{status: :running}} ->
        {:error, :timeout}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
