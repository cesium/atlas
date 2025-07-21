defmodule AtlasWeb.Auth do
  @moduledoc """
  Authentication helper functions.
  """

  import Plug.Conn
  alias Atlas.Accounts

  def get_current_user(conn) do
    user_id = get_session(conn, :user_id)

    case user_id do
      nil -> nil
      id -> Accounts.get_active_user!(id)
    end
  rescue
    Ecto.NoResultsError -> nil
  end

  def logout_user(conn) do
    conn
    |> delete_session(:user_id)
    |> configure_session(drop: true)
  end
end
