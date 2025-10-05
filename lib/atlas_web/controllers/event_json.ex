defmodule AtlasWeb.EventJSON do
  alias Atlas.Events.Event

  @doc """
  Renders a list of events.
  """
  def index(%{events: events}) do
    %{events: for(event <- events, do: data(event))}
  end

  @doc """
  Renders a single event.
  """
  def show(%{event: event}) do
    %{event: data(event)}
  end

  defp data(%Event{} = event) do
    %{
      id: event.id,
      title: event.title,
      start: event.start,
      end: event.end,
      place: event.place,
      link: event.link,
      category:
        if Ecto.assoc_loaded?(event.category) and event.category do
          AtlasWeb.EventCategoryJSON.data(event.category)
        else
          nil
        end
    }
  end
end
