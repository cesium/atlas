defmodule AtlasWeb.EventCategoryControllerTest do
  use AtlasWeb.ConnCase

  import Atlas.EventsFixtures

  alias Atlas.Events.EventCategory

  @create_attrs %{
    name: "some name",
    color: "some color"
  }
  @update_attrs %{
    name: "some updated name",
    color: "some updated color"
  }
  @invalid_attrs %{name: nil, color: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all event_categories", %{conn: conn} do
      conn = get(conn, ~p"/api/event_categories")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create event_category" do
    test "renders event_category when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/event_categories", event_category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/event_categories/#{id}")

      assert %{
               "id" => ^id,
               "color" => "some color",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/event_categories", event_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event_category" do
    setup [:create_event_category]

    test "renders event_category when data is valid", %{conn: conn, event_category: %EventCategory{id: id} = event_category} do
      conn = put(conn, ~p"/api/event_categories/#{event_category}", event_category: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/event_categories/#{id}")

      assert %{
               "id" => ^id,
               "color" => "some updated color",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event_category: event_category} do
      conn = put(conn, ~p"/api/event_categories/#{event_category}", event_category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event_category" do
    setup [:create_event_category]

    test "deletes chosen event_category", %{conn: conn, event_category: event_category} do
      conn = delete(conn, ~p"/api/event_categories/#{event_category}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/event_categories/#{event_category}")
      end
    end
  end

  defp create_event_category(_) do
    event_category = event_category_fixture()
    %{event_category: event_category}
  end
end
