import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Atlas.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Config setup for Corsica
# FIXME add url for frontend
config :atlas, origins: ["http://localhost:3000"]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
