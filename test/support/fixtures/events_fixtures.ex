defmodule Atlas.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Events` context.
  """

  @doc """
  Generate a event_group.
  """
  def event_group_fixture(attrs \\ %{}) do
    {:ok, event_group} =
      attrs
      |> Enum.into(%{
        background_color: "some background_color",
        foreground_color: "some foreground_color",
        name: "some name"
      })
      |> Atlas.Events.create_event_group()

    event_group
  end
end
