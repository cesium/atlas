defmodule AtlasWeb.University.CourseController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses

  def index(conn, params) do
    include_shifts = Map.get(params, "include_shifts", "true") not in ["false", false]

    courses = Courses.list_courses_with_no_parent(include_shifts: include_shifts)

    render(conn, :index, courses: courses)
  end
end
