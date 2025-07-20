defmodule AtlasWeb.CorsPlug do
  @moduledoc """
  A plug to handle CORS requests.
  """

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    origins = Application.get_env(:atlas, :allowed_origins)

    opts =
      Corsica.init(
        origins: origins,
        log: [rejected: :error],
        allow_credentials: true,
        allow_headers: ["authorization", "content-type", "accept"]
      )

    Corsica.call(conn, opts)
  end
end
