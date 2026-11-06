defmodule Atlas.DegreesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University.Degrees` context.
  """
  alias Atlas.University.Degrees
  alias Atlas.University.Degrees.Courses

  @doc """
  Generate a degree.
  """
  def degree_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new_lazy(:code, fn -> "deg_#{System.unique_integer([:positive])}" end)
      |> Map.put_new(:name, "some name")

    {:ok, degree} = Degrees.create_degree(attrs)

    degree
  end

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.new()
      |> Map.put_new_lazy(:code, fn -> "course_#{System.unique_integer([:positive])}" end)
      |> Map.put_new(:name, "some name")
      |> Map.put_new(:semester, 1)
      |> Map.put_new(:year, 1)
      |> Map.put_new_lazy(:degree_id, fn -> degree_fixture().id end)

    {:ok, course} = Courses.create_course(attrs)

    course
  end
end
