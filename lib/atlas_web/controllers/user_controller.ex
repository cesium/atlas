defmodule AtlasWeb.UserController do
  use AtlasWeb, :controller

  alias Atlas.Accounts

  def upload_avatar(conn, %{"id" => user_id, "avatar" => upload}) do
    user_id
    |> get_user()
    |> update_user_avatar(upload)
    |> send_response(conn)
  end

  def upload_avatar(conn, %{"id" => _user_id}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", message: "No avatar file provided"})
  end

  defp get_user(user_id) do
    case Accounts.get_user(user_id) do
      %Atlas.Accounts.User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  defp update_user_avatar({:ok, user}, upload) do
    Accounts.update_user_avatar(user, %{avatar: upload})
  end

  defp update_user_avatar(error, _upload), do: error

  defp send_response({:ok, user}, conn) do
    conn
    |> put_status(:ok)
    |> json(%{
      status: "success",
      message: "Avatar uploaded successfully",
      data: %{avatar_url: Accounts.get_user_avatar_url(user), user_id: user.id}
    })
  end

  defp send_response({:error, reason}, conn) do
    {status, message} = case reason do
      :not_found -> {:not_found, "User not found"}
      %Ecto.Changeset{} -> {:unprocessable_entity, "Avatar validation failed"}
      _ -> {:unprocessable_entity, "Upload failed"}
    end

    conn |> put_status(status) |> json(%{status: "error", message: message})
  end
end
