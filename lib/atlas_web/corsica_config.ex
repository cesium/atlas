defmodule AtlasWeb.Plugs.CorsicaConfig do
  @moduledoc """
  Provides dynamic origin configuration for Corsica based on the environment.
  Allows any origin in dev/test; restricts to known origin(s) in prod.
  """
  def allowed_origins(origin) do
    case Mix.env() do
      :prod ->
        # FIXME add url for frontend
        origin in ["http://localhost:3000"]

      _ ->
        # allow all in dev/test
        true
    end
  end
end
