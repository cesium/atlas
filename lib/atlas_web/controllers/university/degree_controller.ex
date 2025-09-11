defmodule AtlasWeb.University.DegreeController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees

  def index(conn, _params) do
    degrees = Degrees.list_degrees()

    conn
    |> render(:index, degrees: degrees)
  end
end
