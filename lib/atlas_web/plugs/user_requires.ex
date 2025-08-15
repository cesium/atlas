defmodule AtlasWeb.Plugs.UserRequires do
  import Plug.Conn
  import Phoenix.Controller
  alias Atlas.Accounts.Guardian

  @moduledoc """
  A plug that restricts route access based on user types.

  Usage:
    # In your router or controller
    plug AtlasWeb.Plugs.UserRequires, user_types: [:admin, :moderator]

    # Or for a single user type
    plug AtlasWeb.Plugs.UserRequires, user_type: :admin
  """

  def init(args) do
    cond do
      Keyword.has_key?(args, :user_types) ->
        %{user_types: Keyword.get(args, :user_types)}

      Keyword.has_key?(args, :user_type) ->
        %{user_types: [Keyword.get(args, :user_type)]}

      true ->
        raise ArgumentError, "You must provide either the :user_type or :user_types option"
    end
  end

  def call(conn, %{user_types: allowed_types}) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    user_type = user.type

    if user_type_allowed?(user_type, allowed_types) do
      conn
    else
      handle_unauthorized(conn)
    end
  end

  def user_type_allowed?(user_type, allowed_types) do
    user_type in allowed_types
  end

  def handle_unauthorized(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{
      error: "Unauthorized"
    })
    |> halt()
  end
end
