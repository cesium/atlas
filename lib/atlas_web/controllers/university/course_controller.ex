defmodule AtlasWeb.University.CourseController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses

  def index(conn, _params) do
    courses =
      Courses.list_courses_with_no_parent(
        preloads: [[shifts: [:timeslots]], [courses: [shifts: [:timeslots]]]]
      )

    render(conn, :index, courses: courses)
  end
end
