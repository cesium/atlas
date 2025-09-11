defmodule Atlas.Importers.ShiftsByCourses do
  @moduledoc """
  Import shifts by course.
  """

  alias Atlas.University.Degrees
  alias Atlas.University.Degrees.Courses
  alias Atlas.University.Degrees.Courses.Shifts
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

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

      {:error, _} ->
        nil
    end)
  end

  defp import_row(row) do
    %{
      course_name: course_name,
      course_code: course_code,
      number: number,
      type: type,
      professor: professor,
      capacity: capacity,
      start: start_time,
      end: end_time,
      weekday: weekday,
      building: building,
      room: room
    } = parse_row(row)

    if course_code != "" do
      course = ensure_course(course_code, course_name)

      if course do
        shift =
          import_shift(%{
            course: course,
            number: number,
            type: type,
            professor: professor,
            capacity: String.to_integer(capacity)
          })

        import_timeslot(%{
          start: start_time,
          end: end_time,
          weekday: weekday,
          building: building,
          room: room,
          shift: shift
        })
      end
    end
  end

  defp parse_row(row) do
    %{
      course_name: Enum.at(row, 0),
      course_code: Enum.at(row, 2),
      number: Enum.at(row, 4) |> String.replace(~r/[^0-9]/, ""),
      type:
        Enum.at(row, 5)
        |> String.trim()
        |> String.upcase()
        |> then(fn type -> Map.get(@shift_types, type) end),
      professor: Enum.at(row, 7) |> String.trim(),
      start: Enum.at(row, 12),
      end: Enum.at(row, 13),
      capacity: Enum.at(row, 15) |> String.trim(),
      weekday:
        Enum.at(row, 21)
        |> String.to_integer()
        |> then(fn day -> Enum.at(Timeslot.weekdays(), day) end),
      building: Enum.at(row, 10) |> parse_building(),
      room: Enum.at(row, 10) |> parse_room()
    }
  end

  defp ensure_course(code, name) do
    Courses.get_course_by_code(code) ||
      case Courses.create_course(%{
             name: name,
             code: code,
             shortname: Courses.get_shortname_from_name(name),
             semester: Courses.get_semester_from_code(code),
             year: Courses.get_year_from_code(code),
             degree_id: ensure_degree(code)
           }) do
        {:ok, course} -> course
        {:error, _} -> nil
      end
  end

  defp import_shift(%{
         course: course,
         number: number,
         type: type,
         professor: professor,
         capacity: capacity
       }) do
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

  defp import_timeslot(%{
         shift: shift,
         start: start_time,
         end: end_time,
         weekday: weekday,
         building: building,
         room: room
       }) do
    case Shifts.create_timeslot(%{
           shift_id: shift.id,
           start: start_time,
           end: end_time,
           weekday: weekday,
           building: building,
           room: room
         }) do
      {:ok, timeslot} ->
        timeslot

      {:error, _} ->
        nil
    end
  end

  defp ensure_degree(course_code) do
    case Degrees.get_degree_by_code(course_code |> String.slice(0, 2)) do
      nil -> nil
      degree -> degree.id
    end
  end

  defp validate_professor(professor) do
    if @invalid_professor_keywords
       |> Enum.any?(fn keyword -> String.contains?(professor, keyword) end)
       |> Kernel.not() do
      professor
    end
  end

  defp parse_building(location) do
    case location do
      "" ->
        nil

      location ->
        location
        |> String.split("-")
        |> Enum.at(1)
        |> String.trim()
        |> String.split()
        |> Enum.at(1)
    end
  end

  defp parse_room(location) do
    case location do
      "" ->
        nil

      location ->
        location
        |> String.split("-")
        |> Enum.at(2)
        |> String.trim()
    end
  end
end
