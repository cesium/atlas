defmodule Atlas.UniversityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University` context.
  """

  import Atlas.DegreesFixtures

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
  Generate a enrollment.
  """
  def enrollment_fixture(attrs \\ %{}) do
    {:ok, enrollment} =
      attrs
      |> Enum.into(%{
        student_id: student_fixture().id,
        course_id: course_fixture(%{code: "some code"}).id
      })
      |> Atlas.University.create_enrollment()

    enrollment
  end
end
