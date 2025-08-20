defmodule Atlas.Importers.CoursesShifts do
  @moduledoc """
  Import shifts by course.
  """

  alias Atlas.University.Degrees
  alias Atlas.University.Degrees.Courses
  alias Atlas.University.Degrees.Courses.Shifts

  @shift_types %{
    "T" => :theoretical,
    "TP" => :theoretical_practical,
    "PL" => :practical_laboratory,
    "OT" => :tutorial_guidance
  }

  @invalid_professor_keywords ~w(DI DMAT Contratar ,)

  def import_from_csv_file(file_path) do
    File.stream!(file_path)
    |> CSV.decode(separator: ?;)
    |> Enum.drop(1)
    |> Enum.each(fn
      {:ok, row} ->
        import_row(row)

      {:error, reason} ->
        nil
    end)
  end

  defp import_row(row) do
    %{
      course_name: course_name,
      course_shortname: course_shortname,
      course_code: course_code,
      number: number,
      type: type,
      professor: professor,
      capacity: capacity
    } = parse_row(row)

    if course_code != "" do
      course = ensure_course(course_code, course_name, course_shortname)

      if course do
        import_shift(%{
          course: course,
          number: number,
          type: type,
          professor: professor,
          capacity: String.to_integer(capacity)
        })
      end
    end
  end

  defp parse_row(row) do
    %{
      course_name: Enum.at(row, 0),
      course_shortname: Enum.at(row, 1),
      course_code: Enum.at(row, 2),
      number: Enum.at(row, 4) |> String.replace(~r/[^0-9]/, ""),
      type: Enum.at(row, 5) |> String.trim() |> String.upcase() |> then(fn type -> Map.get(@shift_types, type) end),
      professor: Enum.at(row, 7) |> String.trim(),
      capacity: Enum.at(row, 15) |> String.trim(),
    }
  end

  defp ensure_course(code, name, shortname) do
    Courses.get_course_by_code(code) ||
       case Courses.create_course(%{name: name, code: code, shortname: shortname, semester: Courses.get_semester_from_code(code), year: Courses.get_year_from_code(code), degree: maybe_degree(code)}) do
         {:ok, course} -> course
         {:error, error} -> nil
       end
  end

  defp import_shift(%{course: course, number: number, type: type, professor: professor, capacity: capacity}) do
    Shifts.get_shift_by_course_type_number(course.id, type, number) ||
      case Shifts.create_shift(%{
        course_id: course.id,
        number: number,
        type: type,
        professor: validate_professor(professor),
        capacity: capacity
      }) do
        {:ok, shift} -> shift
        {:error, _} -> nil
      end
  end

  defp maybe_degree(course_code) do
    Degrees.get_degree_by_code(course_code |> String.slice(0, 2))
  end

  defp validate_professor(professor) do
    if @invalid_professor_keywords |> Enum.any?(fn keyword -> String.contains?(professor, keyword) end) do
      nil
    else
      professor
    end
  end
end
