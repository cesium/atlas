defmodule AtlasWeb.PreferencesController do
  use AtlasWeb, :controller

  alias Atlas.Accounts

  def get_preferences(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Accounts.get_user_preferences(user.id) do
      nil ->
        json(conn, %{error: "Preferences not found"})

      preferences ->
        conn
        |> put_view(AtlasWeb.UserPreferencesJSON)
        |> render(:show, preferences: preferences)
    end
  end

  def get_preference(conn, %{"preference" => preference}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Accounts.get_user_preference(user.id, preference) do
      {:ok, value} ->
        json(conn, %{preference => value})

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: reason})
    end
  end

  def update_preferences(conn, attrs) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Accounts.set_user_preference(Map.put(attrs, "user_id", user.id)) do
      {:ok, _} ->
        json(conn, %{status: "success", message: "Preferences updated successfully"})

      {:error, :invalid_fields} ->
        json(conn, %{status: "error", message: "No valid fields provided"})

      {:error, _changeset} ->
        json(conn, %{status: "error", message: "No valid values provided"})
    end
  end

  def get_available_preferences(conn, _params) do
    preferences = Accounts.get_available_preferences()
    json(conn, %{preferences: preferences})
  end
end
