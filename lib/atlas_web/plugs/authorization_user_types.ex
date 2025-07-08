defmodule AtlasWeb.Plugs.AuthorizationUserTypes do

  def init(args) do
    cond do
      user_types = args[:user_types] ->
        %{user_types: user_types, on_failure: args[:on_failure] || :redirect}
      user_type = args[:user_type] ->
        %{user_types: [user_type], on_failure: args[:on_failure] || :redirect}
      true ->
        raise ArgumentError, "Must provide either :user_type or :user_types option"
  end

  def call(conn, %{user_types: allowed_types, on_failure: on_failure}) do
    current_user = conn.assigns[:current_user]

    cond do
      is_nil(current_user) ->
        handle_unauthorized(conn, on_failure, :not_authenticated)

      is_nil(Map.get(current_user, :user_type)) ->
        handle_unauthorized(conn, on_failure, :no_user_type)

      current_user.user_type not in allowed_types ->
        handle_unauthorized(conn, on_failure, :insufficient_permissions)

      true ->
        conn
  end

  defp handle_unauthorized(conn, :redirect, reason) do
    conn
      |> redirect(to: "/")
      |> halt()
  end

  defp handle_unauthorized(conn, :json, reason) do
    conn
      |> json(%{error: unauthorized_message(reason)})
      |> halt()
  end

  defp handle_unauthorized(conn, :halt, reason) do
    conn
      |> put_status(:forbidden)
      |> halt()
  end

  defp unauthorized_message(:not_authenticated), do: "You must be logged in"
  defp unauthorized_message(:no_user_type), do: "User type not defined"
  defp unauthorized_message(:insufficient_permissions), do: "You don't have enough permission"

end
