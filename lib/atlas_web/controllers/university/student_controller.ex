defmodule AtlasWeb.University.StudentController do
  use AtlasWeb, :controller

  alias Atlas.University

  def index(conn, params) do
    case University.list_students(params) do
      {:ok, {students, meta}} ->
        conn
        |> render(:index, students: students, meta: meta)

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
    end
  end

  def show(conn, %{"id" => student_id}) do
    student = University.get_student!(student_id, preloads: [:user])

    conn
    |> render(:show, student: student)
  end

  def schedule_index(conn, params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    user = user |> Atlas.Repo.preload(:student)

    courses =
      Atlas.University.list_student_schedule(user.student.id, params["original_only"] == "true")

    conn
    |> put_view(AtlasWeb.University.CourseJSON)
    |> render(:index, courses: courses)
  end

  def student_schedule_index(conn, %{"id" => id}) do
    courses = Atlas.University.list_student_schedule(id, true)

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
