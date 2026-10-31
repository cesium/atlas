defmodule AtlasWeb.EventCategoryController do
  use AtlasWeb, :controller

  alias Atlas.Events
  alias Atlas.Events.EventCategory

  action_fallback AtlasWeb.FallbackController

  def index(conn, _params) do
    event_categories = Events.list_event_categories()
    render(conn, :index, event_categories: event_categories)
  end

  def create(conn, %{"event_category" => event_category_params}) do
    with {:ok, %EventCategory{} = event_category} <-
           Events.create_event_category(event_category_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/v1/event_categories/#{event_category}")
      |> render(:show, event_category: event_category)
    end
  end

  def show(conn, %{"id" => id}) do
    event_category = Events.get_event_category!(id)
    render(conn, :show, event_category: event_category)
  end

  def update(conn, %{"id" => id, "event_category" => event_category_params}) do
    event_category = Events.get_event_category!(id)

    with {:ok, %EventCategory{} = event_category} <-
           Events.update_event_category(event_category, event_category_params) do
      render(conn, :show, event_category: event_category)
    end
  end

  def delete(conn, %{"id" => id}) do
    event_category = Events.get_event_category!(id)

    with {:ok, %EventCategory{}} <- Events.delete_event_category(event_category) do
      send_resp(conn, :no_content, "")
    end
  end

  def selected_index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    user_event_categories = Events.list_event_categories_by_user(user.id)
    render(conn, :index, event_categories: user_event_categories)
  end

  def selected_update(conn, %{"event_categories" => event_categories}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Events.update_event_categories_for_user(user.id, event_categories) do
      {:ok, _} ->
        event_categories = Events.list_event_categories_by_user(user.id)
        render(conn, :index, event_categories: event_categories)

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update selected event categories."})

      {:error, _, _, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Could not update selected event categories."})
    end
  end
end
