defmodule AtlasWeb.ExportController do
  use AtlasWeb, :controller

  alias Atlas.Exporters.Blackboard
  alias Atlas.University.Degrees.Courses

  def blackboard_groups_export(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)

    binary_content =
      Blackboard.blackboard_course_groups_csv(course.id) |> Enum.into([]) |> IO.iodata_to_binary()

    conn
    |> put_status(:ok)
    |> send_download({:binary, binary_content},
      content_type: "text/csv",
      filename: "#{course.code}-#{normalized_course_name(course.name)}-blackboard-groups.csv"
    )
  end

  def blackboard_group_enrollments_export(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)

    binary_content =
      Blackboard.blackboard_course_group_enrollments_csv(course.id)
      |> Enum.into([])
      |> IO.iodata_to_binary()

    conn
    |> put_status(:ok)
    |> send_download({:binary, binary_content},
      content_type: "text/csv",
      filename:
        "#{course.code}-#{normalized_course_name(course.name)}-blackboard-group-enrollments.csv"
    )
  end

  defp normalized_course_name(name) do
    name
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/u, "-")
  end
end
