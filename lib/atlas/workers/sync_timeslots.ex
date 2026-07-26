defmodule Atlas.Workers.SyncTimeslots do
  @moduledoc """
  Worker to sync shift's timeslots using Telescopium.
  """
  use Oban.Worker, queue: :scraper_jobs

  alias Atlas.University.Sync
  alias Atlas.University.Telescopium

  @impl Oban.Worker
  def perform(%Oban.Job{args: args} = _job) do
    config = Map.get(args, "config", %{})

    with {:ok, _} <- Telescopium.request_scrape_job(config),
         {:ok, parsed_shifts} <- poll_until_ready(),
         {:ok, _result} <- Sync.sync_timeslots_from_parsed(parsed_shifts) do
      # Todo Não temos o update_job antes da 2.20

      # Oban.update_job(job, fn job ->
      #   %{
      #     meta:
      #       Map.merge(job.meta || %{}, %{
      #         "status" => "completed",
      #         "updated_count" => result.updated,
      #         "unmatched_count" => length(result.unmatched)
      #       })
      #   }
      # end)

      :ok
    else
      {:error, %Mint.TransportError{reason: :econnrefused}} ->
        {:discard, :service_unavailable}

      {:error, :scraper_server_error} ->
        {:discard, :scraper_server_error}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp poll_until_ready(attempts \\ 0)
  defp poll_until_ready(attempts) when attempts > 10, do: {:error, :timeout}

  defp poll_until_ready(attempts) do
    case Sync.fetch_and_parse() do
      {:ok, parsed_shifts} ->
        {:ok, parsed_shifts}

      :pending ->
        Process.sleep(3_000)
        poll_until_ready(attempts + 1)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
