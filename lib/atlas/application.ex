defmodule Atlas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  defp oban_config do
    Application.fetch_env!(:atlas, Oban)
  end

  @impl true
  def start(_type, _args) do
    children = [
      AtlasWeb.Telemetry,
      Atlas.Repo,
      {DNSCluster, query: Application.get_env(:atlas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Atlas.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Atlas.Finch},
      # Start the Guardian DB token sweeper server
      {Guardian.DB.Sweeper, []},
      # Start Oban for background jobs
      {Oban, oban_config()},
      # Start to serve requests, typically the last entry
      AtlasWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Atlas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AtlasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
