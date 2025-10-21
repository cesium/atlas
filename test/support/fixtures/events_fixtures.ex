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
        color: "some color",
        name: "some name",
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

    defaults = %{
      end: ~N[2025-01-01 14:00:00],
      link: "some link",
      place: "some place",
      start: ~N[2025-01-01 14:00:00],
      title: "some title",
      category_id: category.id
    }

    {:ok, event} =
      attrs
      |> Enum.into(defaults)
      |> Atlas.Events.create_event()

    event
  end
end
