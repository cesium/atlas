defmodule AtlasWeb.University.StudentsController do
  use AtlasWeb, :controller

  def schedule_index(conn, params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    user = user |> Atlas.Repo.preload(:student)

    courses =
      Atlas.University.list_student_schedule(user.student.id, params["original_only"] == "true")

    conn
    |> put_view(AtlasWeb.University.CourseJSON)
    |> render(:index, courses: courses)
  end

  def schedule_update(conn, %{"shifts" => shifts}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    user = user |> Atlas.Repo.preload(:student)

    case Atlas.University.update_student_schedule(user.student.id, shifts) do
      {:ok, %{}} ->
        conn
        # |> put_view(AtlasWeb.University.CourseJSON)
        # |> render(:index, courses: courses)
        |> put_status(:no_content)

      {:error, _, changeset} ->
        conn
        |> put_view(AtlasWeb.University.CourseJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
