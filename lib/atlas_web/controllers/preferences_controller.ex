defmodule AtlasWeb.PreferencesController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  alias Atlas.Accounts

  def get_preferences(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    preferences = Accounts.get_user_preferences(user.id)
    json(conn, %{
      user_id: preferences.user_id,
      language: preferences.language
    })
  end

  def get_preference(conn, %{"preference" => preference}) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    preference_value = Accounts.get_user_preference(user.id, preference)
    case preference_value do
      nil -> json(conn, %{error: "Preference not found"})
      _ -> json(conn, %{preference => preference_value})
    end
  end

  def update_preference(conn, %{"preference" => preference, "value" => value}) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    case Accounts.set_user_preference(user.id, preference, value) do
      {:ok, _} -> json(conn, %{status: "success", message: "Preference updated successfully"})
      {:error, _} -> json(conn, %{status: "error", message: "Invalid preference or value"})
    end
  end
end
