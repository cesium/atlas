defmodule AtlasWeb.EventController do
  use AtlasWeb, :controller

  alias Atlas.Events
  alias Atlas.Events.Event

  action_fallback AtlasWeb.FallbackController

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, :index, events: events)
  end

  def selected_index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    events = Events.list_events_by_user(user.id)
    render(conn, :index, events: events)
  end

  def create(conn, %{"event" => event_params}) do
    with {:ok, %Event{} = event} <- Events.create_event(event_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/v1/events/#{event}")
      |> render(:show, event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    render(conn, :show, event: event)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    with {:ok, %Event{} = event} <- Events.update_event(event, event_params) do
      render(conn, :show, event: event)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)

    with {:ok, %Event{}} <- Events.delete_event(event) do
      send_resp(conn, :no_content, "")
    end
  end
end
