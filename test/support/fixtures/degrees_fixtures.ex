defmodule Atlas.DegreesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Degrees` context.
  """

  @doc """
  Generate a degree.
  """
  def degree_fixture(attrs \\ %{}) do
    {:ok, degree} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Atlas.Degrees.create_degree()

    degree
  end

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        name: "some name",
        semester: 42,
        year: 42
      })
      |> Atlas.Degrees.create_course()

    course
  end
end
