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
      {:ok, _} ->
        courses =
          Atlas.University.list_student_schedule(user.student.id)

        conn
        |> put_view(AtlasWeb.University.CourseJSON)
        |> render(:index, courses: courses)

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update schedule."})

      {:error, _, _, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update schedule."})
    end
  end
end
