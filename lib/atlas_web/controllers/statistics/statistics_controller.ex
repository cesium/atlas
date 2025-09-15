defmodule AtlasWeb.StatisticsController do
  use AtlasWeb, :controller

  alias Atlas.Statistics
  alias Atlas.University.Degrees.Courses

  def course_shifts_capacity(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)

    conn
    |> json(%{shifts: Statistics.course_shifts_capacity_occupation(course.id)})
  end
end
