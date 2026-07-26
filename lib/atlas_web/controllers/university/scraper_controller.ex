defmodule AtlasWeb.University.ScraperController do
  use AtlasWeb, :controller

  alias Atlas.University

  def link_timeslots(conn, config \\ %{}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case University.Sync.queue_link_timeslots(config, user) do
      {:ok, job} ->
        conn
        |> json(%{job_id: job.id, message: "Scrape & Link job queued successfully."})

      {:error, :service_unavailable} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Scrape service is unavailable."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not queue Scrape & Link job: #{reason}."})
    end
  end

  def sync_timeslots(conn, config \\ %{}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case University.Sync.queue_sync_timeslots(config, user) do
      {:ok, job} ->
        conn
        |> json(%{job_id: job.id, message: "Scrape & Sync job queued successfully."})

      {:error, :service_unavailable} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Scrape service is unavailable."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not queue Scrape & Sync job: #{reason}."})
    end
  end

  def toggle_auto_sync(conn, _params) do
    case University.Sync.toggle_auto_sync() do
      {:ok, data} ->
        conn
        |> json(%{state: data.value["auto_sync"], message: "Auto Sync state updated."})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update Auto Sync state: #{reason}."})
    end
  end

  def get_auto_sync_state(conn, _params) do
    case University.Sync.get_auto_sync_state() do
      {:ok, state} ->
        conn
        |> json(%{state: state})

      nil ->
        conn
        |> json(%{error: "Auto Sync state is nil"})
    end
  end
end
