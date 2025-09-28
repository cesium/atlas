defmodule Atlas.Exporters.Blackboard do
  @moduledoc """
  Export data to Blackboard format.
  """
  use Atlas.Context

  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias Atlas.University.ShiftEnrollment

  def blackboard_course_groups_csv(course_id) do
    Shift
    |> where([s], s.course_id == ^course_id)
    |> order_by([s], asc: s.type, asc: s.number)
    |> Repo.all()
    |> Enum.map(&format_course_group_row/1)
    |> then(&[["Group Code", "Title", "Description", "Group Set", "Self Enroll"] | &1])
    |> CSV.encode(force_escaping: true)
  end

  def blackboard_course_group_enrollments_csv(course_id) do
    ShiftEnrollment
    |> join(:inner, [se], s in Shift, on: se.shift_id == s.id)
    |> where([se, s], se.status in [:active, :inactive])
    |> where([se, s], s.course_id == ^course_id)
    |> order_by([se, s], asc: s.type, asc: s.number)
    |> preload([se, s], [:student, :shift])
    |> preload([se, s], student: [:user])
    |> Repo.all()
    |> Enum.map(&format_course_group_enrollment_row/1)
    |> then(
      &[["Group Code", "User Name", "Student Id", "First Name", "Last Name", "Group Set"] | &1]
    )
    |> CSV.encode(force_escaping: true)
  end

  defp format_course_group_row(shift) do
    shift_short_name = Shift.short_name(shift)

    [
      shift_short_name <> "_gc",
      shift_short_name,
      nil,
      "Turmas (#{Shift.short_type(shift)})",
      "N"
    ]
  end

  defp format_course_group_enrollment_row(%ShiftEnrollment{student: student, shift: shift}) do
    shift_short_name = Shift.short_name(shift)
    normalized_student_number = String.downcase(student.number)

    [
      shift_short_name <> "_gc",
      normalized_student_number,
      normalized_student_number |> String.replace("a", "") |> String.replace("pg", ""),
      student.user.name,
      ".",
      "Turmas (#{Shift.short_type(shift)})"
    ]
  end
end
