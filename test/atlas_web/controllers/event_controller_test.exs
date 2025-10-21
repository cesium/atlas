defmodule AtlasWeb.EventControllerTest do
  use AtlasWeb.ConnCase

  import Atlas.EventsFixtures

  alias Atlas.Events.Event

  @create_attrs %{
    start: "2025-01-01T14:00:00Z",
    link: "some link",
    title: "some title",
    end: "2025-01-01T14:00:00Z",
    place: "some place"
  }
  @update_attrs %{
    start: "2025-01-01T15:01:01Z",
    link: "some updated link",
    title: "some updated title",
    end: "2025-01-01T15:01:01Z",
    place: "some updated place"
  }
  @invalid_attrs %{start: nil, link: nil, title: nil, end: nil, place: nil}

  setup %{conn: _conn} do
    conn = AtlasWeb.ConnCase.authenticated_conn(%{type: :professor})
    category = event_category_fixture()

    create_attrs = Map.put(@create_attrs, :category_id, category.id)
    update_attrs = Map.put(@update_attrs, :category_id, category.id)

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     create_attrs: create_attrs,
     update_attrs: update_attrs}
  end

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, ~p"/v1/events")
      assert json_response(conn, 200)["events"] == []
    end
  end

  describe "create event" do
    test "renders event when data is valid", %{conn: conn, create_attrs: create_attrs} do
      conn = post(conn, ~p"/v1/events", event: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["event"]

      conn = get(conn, ~p"/v1/events/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-01-01T14:00:00Z",
               "link" => "some link",
               "place" => "some place",
               "start" => "2025-01-01T14:00:00Z",
               "title" => "some title"
             } = json_response(conn, 200)["event"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/v1/events", event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event" do
    setup [:create_event]

    test "renders event when data is valid", %{
      conn: conn,
      event: %Event{id: id} = event,
      update_attrs: update_attrs
    } do
      conn = put(conn, ~p"/v1/events/#{event}", event: update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["event"]

      conn = get(conn, ~p"/v1/events/#{id}")

      assert %{
               "id" => ^id,
               "end" => "2025-01-01T15:01:01Z",
               "link" => "some updated link",
               "place" => "some updated place",
               "start" => "2025-01-01T15:01:01Z",
               "title" => "some updated title"
             } = json_response(conn, 200)["event"]
    end

    test "renders errors when data is invalid", %{conn: conn, event: event} do
      conn = put(conn, ~p"/v1/events/#{event}", event: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event" do
    setup [:create_event]

    test "deletes chosen event", %{conn: conn, event: event} do
      conn = delete(conn, ~p"/v1/events/#{event}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/v1/events/#{event}")
      end
    end
  end

  defp create_event(_) do
    event = event_fixture()
    %{event: event}
  end
end
