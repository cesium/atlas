defmodule AtlasWeb.AuthController do
  use AtlasWeb, :controller

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Accounts.Guardian

  action_fallback AtlasWeb.FallbackController

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        access_token = generate_access_token(user)

        conn
        |> json(%{
          token: access_token,
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

  def refresh(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    if user do
      access_token = generate_access_token(user)

      conn
      |> json(%{token: access_token})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Not authenticated"})
    end
  end

  defp generate_access_token(user) do
    {:ok, token, _claims} =
      Guardian.encode_and_sign(user, %{aud: "astra"}, token_type: "access", ttl: {7, :day})

    token
  end
end
