defmodule AtlasWeb.UserSessionJSON do
  alias Atlas.Accounts.UserSession

  @doc """
  Renders a list of users_sessions.
  """
  def index(%{users_sessions: users_sessions}) do
    %{data: for(user_session <- users_sessions, do: data(user_session))}
  end

  @doc """
  Renders a single user_session.
  """
  def show(%{user_session: user_session}) do
    %{data: data(user_session)}
  end

  defp data(%UserSession{} = user_session) do
    %{
      id: user_session.id,
      ip: user_session.ip,
      user_agent: user_session.user_agent
    }
  end
end
