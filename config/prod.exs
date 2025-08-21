import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Atlas.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Configures Waffle
config :waffle,
  storage: Waffle.Storage.S3,
  bucket: {:system, "AWS_S3_BUCKET"},
  asset_host: {:system, "ASSET_HOST"}

# Configure ExAws
config :ex_aws,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"},
  region: {:system, "AWS_REGION"},
  s3: [
    scheme: "https://",
    host: {:system, "ASSET_HOST"},
    region: {:system, "AWS_REGION"},
    access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
    secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}
  ]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
