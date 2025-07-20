defmodule AtlasWeb.PageController do
  use AtlasWeb, :controller

  def index(conn, _params) do
    conn
    |> json(%{
      atlas: "Alive... for now. If not, dig deeper."
    })
  end
end
