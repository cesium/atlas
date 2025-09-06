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

  describe "get_preference/2" do
    test "returns the specific preference (language)", %{authenticated_conn: conn} do
      PreferencesController.update_preferences(conn, %{
        "language" => "en-US"
      })

      conn = PreferencesController.get_preference(conn, %{"preference" => "language"})

      response = json_response(conn, 200)
      assert Map.has_key?(response, "language")
      assert response["language"] == "en-US"
    end

    test "returns error for non-existent preference", %{authenticated_conn: conn} do
      conn = PreferencesController.get_preference(conn, %{"preference" => "none"})

      response = json_response(conn, 404)
      assert response["error"] == "Preference not found"
    end
  end

  describe "update_preference/2" do
    test "updates the specific preference", %{authenticated_conn: conn} do
      conn =
        PreferencesController.update_preferences(conn, %{
          "language" => "pt-PT"
        })

      response = json_response(conn, 200)
      assert response["status"] == "success"
      assert response["message"] == "Preferences updated successfully"
    end

    test "returns error for invalid fields", %{authenticated_conn: conn} do
      conn =
        PreferencesController.update_preferences(conn, %{
          "invalid_field" => "value"
        })

      response = json_response(conn, 200)
      assert response["status"] == "error"
      assert response["message"] == "No valid fields provided"
    end

    test "returns error for invalid values", %{authenticated_conn: conn} do
      conn =
        PreferencesController.update_preferences(conn, %{
          "language" => "invalid_value"
        })

      response = json_response(conn, 200)
      assert response["status"] == "error"
      assert response["message"] == "No valid values provided"
    end
  end

  describe "get_available_preferences/2" do
    test "returns available preferences", %{authenticated_conn: conn} do
      conn = PreferencesController.get_available_preferences(conn, %{})

      response = json_response(conn, 200)
      assert Map.has_key?(response, "preferences")
      assert is_list(response["preferences"])
      assert "language" in response["preferences"]
    end
  end
end
