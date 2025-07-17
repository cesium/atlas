defmodule AtlasWeb.UserSessionJSON do
  alias Atlas.Accounts.UserSession

  @doc """
  Renders a list of users_sessions.
  """
  def index(%{users_sessions: users_sessions}) do
    %{sessions: for(user_session <- users_sessions, do: data(user_session))}
  end

  @doc """
  Renders a single user_session.
  """
  def show(%{user_session: user_session}) do
    %{session: data(user_session)}
  end

  defp data(%UserSession{} = user_session) do
    %{
      id: user_session.id,
      ip: user_session.ip,
      user_os: user_session.user_os,
      user_browser: user_session.user_browser,
      user_agent: user_session.user_agent,
      first_seen: user_session.inserted_at
    }
  end
end
