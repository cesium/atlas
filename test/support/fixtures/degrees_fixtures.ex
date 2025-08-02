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
        code: "code",
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
        code: "code",
        name: "some name",
        semester: 1,
        year: 1,
        degree_id: degree_fixture(%{code: "some code"}).id
      })
      |> Atlas.Degrees.create_course()

    course
  end
end
