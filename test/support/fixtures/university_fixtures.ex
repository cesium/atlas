defmodule Atlas.UniversityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University` context.
  """

  import Atlas.DegreesFixtures
  import Atlas.University.Degrees.Courses.ShiftsFixtures

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        degree_year: 42,
        number: "some number",
        special_status: "some special_status",
        degree_id: degree_fixture().id
      })
      |> Atlas.University.create_student()

    student
  end

  @doc """
  Generate a course enrollment.
  """
  def course_enrollment_fixture(attrs \\ %{}) do
    {:ok, course_enrollment} =
      attrs
      |> Enum.into(%{
        student_id: student_fixture().id,
        course_id: course_fixture(%{code: "some code"}).id
      })
      |> Atlas.University.create_course_enrollment()

    course_enrollment
  end

  @doc """
  Generate a shift_enrollment.
  """
  def shift_enrollment_fixture(attrs \\ %{}) do
    {:ok, shift_enrollment} =
      attrs
      |> Enum.into(%{
        status: :active,
        student_id: student_fixture().id,
        shift_id: shift_fixture().id
      })
      |> Atlas.University.create_shift_enrollment()

    shift_enrollment
  end
end
