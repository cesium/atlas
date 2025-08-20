defmodule Atlas.Importers.StudentsByCourses do
  @moduledoc """
  Import students by course.
  """
  alias Atlas.{Accounts, University}
  alias University.Degrees
  alias Degrees.Courses

  def import_from_excel_file(file_path) do
    with {:ok, package} <- XlsxReader.open(file_path),
         [sheet | _] <- XlsxReader.sheet_names(package),
         {:ok, rows} <- XlsxReader.sheet(package, sheet) do
      rows
      |> Enum.drop(7)
      |> Enum.each(&import_row/1)
    end
  end

  defp import_row(row) do
    %{
      degree_code: degree_code,
      degree_name: degree_name,
      student_number: student_number,
      name: name,
      email: email,
      special_status: special_status,
      course_code: course_code,
      course_name: course_name,
      parent_code: parent_code,
      parent_name: parent_name,
      year: year
    } = parse_row(row)

    degree = ensure_degree(degree_code, degree_name)

    user = ensure_user(email, name, student_number, special_status, degree)

    course =
      if course_name != "" do
        import_course(%{
          code: course_code,
          name: course_name,
          parent_code: parent_code,
          parent_name: parent_name,
          year: year,
          degree: degree
        })
      end

    import_enrollment(course, user.student)
  end

  defp parse_row(row) do
    %{
      degree_code: Enum.at(row, 3),
      degree_name: Enum.at(row, 4),
      year: Enum.at(row, 6) |> round(),
      course_code: Enum.at(row, 7),
      course_name: Enum.at(row, 8),
      parent_code: Enum.at(row, 9),
      parent_name: Enum.at(row, 10),
      student_number: Enum.at(row, 11),
      name: Enum.at(row, 12),
      email: Enum.at(row, 13),
      special_status: Enum.at(row, 15)
    }
  end

  defp ensure_degree(code, name) do
    Degrees.get_degree_by_code(code) ||
      case Degrees.create_degree(%{name: name, code: code}) do
        {:ok, degree} -> degree
        {:error, _} -> nil
      end
  end

  defp ensure_user(email, name, student_number, special_status, degree) do
    Accounts.get_user_by_email(email, preloads: [:student]) ||
      case Accounts.register_student_user_with_random_password(%{
             name: name,
             email: email,
             student: %{
               number: student_number,
               degree_id: degree.id,
               special_status: special_status
             }
           }) do
        {:ok, user} -> user
        {:error, _, _} -> nil
      end
  end

  defp import_course(%{code: code, name: name, parent_code: "", year: year, degree: degree}) do
    semester = Courses.get_semester_from_code(code)

    get_or_create_course(%{
      code: code,
      name: name,
      year: year,
      semester: semester,
      degree_id: degree.id
    })
  end

  defp import_course(%{
         code: code,
         name: name,
         parent_code: parent_code,
         parent_name: parent_name,
         year: year,
         degree: degree
       }) do
    semester = Courses.get_semester_from_code(parent_code)

    parent_course =
      case String.at(code, 2) |> Integer.parse() do
        {_, _} ->
          nil

        _ ->
          get_or_create_course(%{
            code: parent_code,
            name: parent_name,
            year: year,
            semester: semester,
            degree_id: degree.id
          })
      end

    get_or_create_course(%{
      code: code,
      name: name,
      year: year,
      semester: semester,
      degree_id: degree.id,
      parent_course_id: parent_course && parent_course.id
    })
  end

  defp import_enrollment(course, student) do
    if course && student do
      University.enroll_student_in_course(student, course)
    end
  end

  defp get_or_create_course(attrs) do
    Courses.get_course_by_code(attrs.code) ||
      case Courses.create_course(attrs) do
        {:ok, course} -> course
        {:error, _} -> nil
      end
  end
end
