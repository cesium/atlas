defmodule Atlas.UniversityFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.University` context.
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
      |> Atlas.University.create_degree()

    degree
  end
end
