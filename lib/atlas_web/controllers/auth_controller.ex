defmodule AtlasWeb.AuthController do
  use AtlasWeb, :controller

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Accounts.Guardian

  action_fallback AtlasWeb.FallbackController

  @refresh_token_days 7

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        ip = conn.remote_ip |> :inet.ntoa() |> to_string()

        user_agent =
          List.first(Plug.Conn.get_req_header(conn, "user-agent"), "") |> parse_user_agent()

        case Accounts.create_user_session(
               user,
               ip,
               user_agent.agent,
               user_agent.os,
               user_agent.browser
             ) do
          {:ok, session} ->
            access_token = generate_token(user, session, :access)
            refresh_token = generate_token(user, session, :refresh)

            conn
            |> insert_refresh_token_cookie(refresh_token)
            |> json(%{
              access_token: access_token,
              session_id: session.id
            })

          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to create user session"})
        end

      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def me(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    if user do
      conn
      |> put_view(AtlasWeb.UserJSON)
      |> render(:show, user: user)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    end
  end

  def refresh_token(conn, _params) do
    case fetch_refresh_token_cookie(conn) do
      {:ok, old_refresh_token} ->
        with {:ok, old_claims} <-
               Guardian.decode_and_verify(old_refresh_token, %{"typ" => "refresh"}),
             {:ok, {user, session}} <- Guardian.resource_from_claims(old_claims),
             {:ok, _claims} <- Guardian.revoke(old_refresh_token) do
          access_token = generate_token(user, session, :access)
          new_refresh_token = generate_token(user, session, :refresh)

          conn
          |> insert_refresh_token_cookie(new_refresh_token)
          |> json(%{
            access_token: access_token
          })
        else
          _ ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid or expired refresh token"})
        end

      :error ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Refresh token not found"})
    end
  end

  def sign_out(conn, _params) do
    {_user, session} = Guardian.Plug.current_resource(conn)

    if session do
      case Accounts.delete_user_session(session) do
        {:ok, _} ->
          conn
          |> delete_refresh_token_cookie()
          |> put_status(:no_content)
          |> send_resp(:no_content, "")

        {:error, _reason} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{error: "Failed to sign out"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    end
  end

  def sessions(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    if user do
      sessions = Accounts.list_user_sessions(user.id)

      conn
      |> put_view(AtlasWeb.UserSessionJSON)
      |> render(:index, users_sessions: sessions)
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    end
  end

  defp fetch_refresh_token_cookie(conn) do
    conn = fetch_cookies(conn, signed: ["refresh_token"])

    case conn.cookies["refresh_token"] do
      nil -> :error
      token -> {:ok, token}
    end
  end

  defp insert_refresh_token_cookie(conn, token) do
    put_resp_cookie(conn, "refresh_token", token,
      http_only: true,
      secure: true,
      same_site: "Strict",
      max_age: @refresh_token_days * 24 * 60 * 60,
      sign: true
    )
  end

  defp delete_refresh_token_cookie(conn) do
    delete_resp_cookie(conn, "refresh_token",
      http_only: true,
      secure: true,
      same_site: "Strict",
      max_age: @refresh_token_days * 24 * 60 * 60,
      sign: true
    )
  end

  defp generate_token(user, session, :access) do
    {:ok, token, _claims} =
      Guardian.encode_and_sign({user, session}, %{aud: "astra"},
        token_type: "access",
        ttl: {15, :minute}
      )

    token
  end

  defp generate_token(user, session, :refresh) do
    {:ok, token, _claims} =
      Guardian.encode_and_sign({user, session}, %{aud: "astra"},
        token_type: "refresh",
        ttl: {@refresh_token_days, :day}
      )

    token
  end

  defp parse_user_agent(user_agent) do
    ua = UAParser.parse(user_agent)

    %{
      os: to_string(ua.os),
      browser: to_string(ua.family),
      agent: user_agent
    }
  end
end
