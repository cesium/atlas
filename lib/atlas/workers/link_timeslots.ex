defmodule Atlas.Workers.LinkTimeslots do
  @moduledoc """
  Worker to link shift's timeslots using Telescopium.
  """
  use Oban.Worker, queue: :schedule_generator

  alias Atlas.University.Sync
  alias Atlas.University.Telescopium

  @impl Oban.Worker
  def perform(%Oban.Job{args: args} = _job) do
    config = Map.get(args, "config", %{})

    case Telescopium.request_scrape_job(config) do
      {:ok, _} ->
        case poll_until_ready() do
          {:ok, parsed_shifts} ->
            case Sync.link_timeslots_from_parsed(parsed_shifts) do
              {:ok, _result} ->
                :ok

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

              {:error, reason} ->
                {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp poll_until_ready(attempts \\ 0)
  defp poll_until_ready(attempts) when attempts > 20, do: {:error, :timeout}

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
