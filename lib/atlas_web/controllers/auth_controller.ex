defmodule AtlasWeb.AuthController do
  use AtlasWeb, :controller

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Accounts.Guardian

  action_fallback AtlasWeb.FallbackController

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        {:ok, access_token, _claims} =
          Guardian.encode_and_sign(user, %{}, token_type: "access", ttl: {7, :day})

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
end
