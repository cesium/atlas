defmodule AtlasWeb.AuthController do
  use AtlasWeb, :controller

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Accounts.Guardian

  action_fallback AtlasWeb.FallbackController

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        access_token = generate_token(user, :access)
        refresh_token = generate_token(user, :refresh)

        conn
        |> json(%{
          access_token: access_token,
          refresh_token: refresh_token,
          user: %{
            id: user.id,
            email: user.email,
            name: user.name
          }
        })

      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

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

  def refresh_token(conn, %{"refresh_token" => old_refresh_token}) do
    with {:ok, old_claims} <-
           Guardian.decode_and_verify(old_refresh_token, %{"typ" => "refresh"}),
         {:ok, user} <- Guardian.resource_from_claims(old_claims),
         {:ok, _claims} <- Guardian.revoke(old_refresh_token) do
      # Issue new access and refresh tokens
      access_token = generate_token(user, :access)
      new_refresh_token = generate_token(user, :refresh)

      conn
      |> json(%{
        access_token: access_token,
        refresh_token: new_refresh_token
      })
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid or expired refresh token"})
    end
  end

  defp generate_token(user, :access) do
    {:ok, token, _claims} =
      Guardian.encode_and_sign(user, %{aud: "astra"}, token_type: "access", ttl: {15, :minute})

    token
  end

  defp generate_token(user, :refresh) do
    {:ok, token, _claims} =
      Guardian.encode_and_sign(user, %{aud: "astra"}, token_type: "refresh", ttl: {7, :day})

    token
  end
end
