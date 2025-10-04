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
        name: "some name"
      })
      |> Atlas.Events.create_event_category()

    event_category
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        end: ~T[14:00:00],
        link: "some link",
        place: "some place",
        start: ~T[14:00:00],
        title: "some title"
      })
      |> Atlas.Events.create_event()

    event
  end
end
