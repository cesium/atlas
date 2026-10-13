defmodule AtlasWeb.PublicEventJSON do
  alias Atlas.Events.Event

  @doc """
  Renders a list of public events as a direct JSON array.
  Compatible with the consumer interface: {title, start, end, place, link}.
  """
  def index(%{events: events}) do
    for event <- events, do: data(event)
  end

  defp data(%Event{} = event) do
    %{
      title: event.title,
      start: event.start,
      end: event.end,
      place: event.place,
      link: event.link
    }
  end
end
