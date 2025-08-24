defmodule AtlasWeb.University.StudentsController do
  use AtlasWeb, :controller

  def index(conn, _params) do
    render(conn, :index, students: [])
  end
end
