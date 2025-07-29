defmodule Atlas.MixProject do
  use Mix.Project

  def project do
    [
      app: :atlas,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Atlas.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # core
      {:phoenix, "~> 1.7.12"},
      {:jason, "~> 1.2"},

      # database
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # security
      {:bcrypt_elixir, "~> 3.0"},

      # auth
      {:guardian, "~> 2.3"},
      {:guardian_db, "~> 3.0"},

      # mailer
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},

      # job processing
      {:oban, "~> 2.17"},

      # tools
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},

      # monitoring
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},

      # server
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},

      # cors
      {:corsica, "~> 2.1.3"},

      # utilities
      {:remote_ip, "~> 1.2"},
      {:ua_parser, "~> 1.8"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      lint: ["credo --all --strict"]
    ]
  end
end
