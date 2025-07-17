import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :atlas, Atlas.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "atlas_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :atlas, AtlasWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v6DII6ih4LfA0e8erY+yaf7xvhGTQI3PvX+CyaDOigUWPqgo5xs12Y98gcJ/08PN",
  server: false

config :atlas, Atlas.Accounts.Guardian,
  issuer: "atlas",
  secret_key: "test-secret-key-for-testing-purposes-only",
  ttl: {1, :hour},
  allowed_drift: 2000

config :guardian, Guardian.DB,
  repo: Atlas.Repo,
  schema_name: "sessions_tokens",
  sweep_interval: 60,
  token_types: ["refresh"]

# In test we don't send emails.
config :atlas, Atlas.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true

# Add this to your test config
config :bcrypt_elixir, log_rounds: 4
