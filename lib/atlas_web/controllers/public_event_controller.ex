defmodule AtlasWeb.PublicEventController do
  use AtlasWeb, :controller

  alias Atlas.Events

  def index(conn, _params) do
    events = Events.list_cesium_events()
    render(conn, :index, events: events)
  end
end
