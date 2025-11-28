defmodule Atlas.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Events` context.
  """

  @doc """
  Generate a event_category.
  """
  def event_category_fixture(attrs \\ %{}) do
    {:ok, event_category} =
      attrs
      |> Enum.into(%{
        name: "some name",
        color: "#abcdef",
        type: "optional"
      })
      |> Atlas.Events.create_event_category()

    event_category
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    category = event_category_fixture()

    {:ok, event} =
      attrs
      |> Enum.into(%{
        title: "some title",
        start: ~U[2025-01-01T14:00:00Z],
        end: ~U[2025-01-01T15:00:00Z],
        place: "some place",
        link: "some link",
        category_id: category.id
      })
      |> Atlas.Events.create_event()

    event
  end
end
