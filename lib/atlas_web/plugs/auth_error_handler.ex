defmodule AtlasWeb.Plugs.AuthErrorHandler do
  import Plug.Conn
  alias Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_status(401)
    |> Controller.json(%{error: "Invalid or expired token"})
  end
end
