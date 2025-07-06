defmodule AtlasWeb.Plugs.GuardianErrorHandler do
  import Plug.Conn
  alias Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    conn
    |> put_resp_content_type("text/plain")
    |> put_status(401)
    |> Controller.json(%{error: body})
  end
end
