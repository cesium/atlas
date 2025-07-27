defmodule Atlas.UniversityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        degree_year: 42,
        number: "some number",
        special_status: "some special_status"
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
      |> Enum.into(%{})
      |> Atlas.University.create_enrollment()

    enrollment
  end
end
