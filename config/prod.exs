import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Atlas.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Configures CORS allowed origins
config :atlas,
       :allowed_origins,
       System.get_env("FRONTEND_URL") ||
         raise("""
         environment variable FRONTEND_URL is missing.
         This should be the URL of your frontend application.
         """)

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
