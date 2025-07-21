defmodule AtlasWeb.UserController do
  use AtlasWeb, :controller

  alias Atlas.Accounts
  alias AtlasWeb.Auth

  plug :authenticate_user when action in [:update_password, :update_profile, :delete_account]

  plug :authorize_user when action in [:update_password, :update_profile, :delete_account]

  def update_password(conn, %{"password" => password_params}) do
    current_user = conn.assigns[:current_user]

    case Accounts.update_user_password(current_user, password_params) do
      {:ok, _user} ->
        conn
        |> json(%{success: true, message: "Password updated successfully"})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          message: "Failed to update password",
          errors: format_changeset_errors(changeset)
        })
    end
  end

  def update_profile(conn, %{"profile" => profile_params}) do
    current_user = conn.assigns[:current_user]

    profile_params = handle_profile_picture_upload(profile_params)

    case Accounts.update_user_profile(current_user, profile_params) do
      {:ok, user} ->
        conn
        |> json(%{
          success: true,
          message: "Profile updated successfully",
          user: %{
            id: user.id,
            email: user.email,
            gender: user.gender,
            profile_picture: user.profile_picture,
            birth_date: user.birth_date
          }
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          message: "Failed to update profile",
          errors: format_changeset_errors(changeset)
        })
    end
  end

  def delete_account(conn, _params) do
    current_user = conn.assigns[:current_user]

    case Accounts.delete_user_account(current_user) do
      {:ok, _user} ->
        conn
        |> Auth.logout_user()
        |> json(%{
          success: true,
          message: "Account deleted successfully"
        })

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          message: "Failed to delete account",
          errors: format_changeset_errors(changeset)
        })
    end
  end

  defp authenticate_user(conn, _opts) do
    case Auth.get_current_user(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{success: false, message: "Authentication required"})
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end

  defp authorize_user(conn, _opts) do
    current_user = conn.assigns[:current_user]
    user_id = conn.params["id"]

    if current_user.id == user_id do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{success: false, message: "Access denied"})
      |> halt()
    end
  end

  defp handle_profile_picture_upload(params) do
    case params["profile_picture"] do
      %Plug.Upload{} = upload ->
        case upload_file(upload) do
          {:ok, file_url} ->
            Map.put(params, "profile_picture", file_url)

          {:error, _} ->
            Map.delete(params, "profile_picture")
        end

      nil ->
        Map.delete(params, "profile_picture")

      _ ->
        params
    end
  end

  defp upload_file(%Plug.Upload{filename: filename, path: path}) do
    extension = Path.extname(filename)
    new_filename = "#{Ecto.UUID.generate()}#{extension}"
    destination = Path.join(["priv", "static", "uploads", new_filename])

    case File.cp(path, destination) do
      :ok ->
        {:ok, "/uploads/#{new_filename}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
