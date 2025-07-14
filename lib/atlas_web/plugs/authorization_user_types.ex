defmodule AtlasWeb.Plugs.UserRequires do
  import Plug.Conn
  import Phoenix.Controller
  alias Atlas.Accounts.Guardian

  @moduledoc """
  A plug that restricts route access based on user types.

  Usage:
    # In your router or controller
    plug MyAppWeb.Plugs.UserRequires, user_types: [:admin, :moderator]

    # Or for a single user type
    plug MyAppWeb.Plugs.UserRequires, user_type: :admin
  """

  def init(args) do
    cond do
      user_types = args[:user_types] ->
        %{user_types: user_types}

      user_type = args[:user_type] ->
        %{user_types: [user_type]}

      true ->
        raise ArgumentError, "Must provide either :user_type or :user_types option"
    end
  end

  def call(conn, %{user_types: allowed_types}) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    user_type = user.type

    case user_type_allowed?(user_type, allowed_types) do
      true ->
        conn

      false ->
        handle_unauthorized(conn, user, allowed_types)
    end

    conn
  end

  def user_type_allowed?(user_type, allowed_types) do
    user_type in allowed_types
  end

  def handle_unauthorized(conn, user, allowed_types) do
    conn
    |> put_status(:forbidden)
    |> json(%{
      error: "Unauthorized access",
      user_type: user.type,
      allowed_types: allowed_types
    })
    |> halt()
  end
end
