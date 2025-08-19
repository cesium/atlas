defmodule Atlas.PreferencesTest do
  use AtlasWeb.ConnCase

  alias AtlasWeb.PreferencesController

  setup do
    conn = authenticated_conn(%{type: :student})
    {user, _session} = Guardian.Plug.current_resource(conn)

    %{
      authenticated_conn: conn,
      user: user
    }
  end

  describe "get_preferences/2" do
    test "returns the user's preferences", %{authenticated_conn: conn, user: user} do
      conn = PreferencesController.get_preferences(conn, %{})

      response = json_response(conn, 200)
      assert response["user_id"] == user.id
      assert response["language"] == "en-US"
    end
  end

  describe "get_preference/2" do
    test "returns the specific preference (language)", %{authenticated_conn: conn} do
      conn = PreferencesController.get_preference(conn, %{"preference" => "language"})
      response = json_response(conn, 200)
      assert Map.has_key?(response, "language")
      assert response["language"] == "en-US"
    end
  end

  describe "update_preference/2" do
    test "updates the specific preference", %{authenticated_conn: conn} do
      conn = PreferencesController.update_preference(conn, %{"preference" => "language", "value" => "pt-PT"})

      response = json_response(conn, 200)
      assert response["status"] == "success"
      assert response["message"] == "Preference updated successfully"
    end
  end
end
