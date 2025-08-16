defmodule AtlasWeb.UserController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  alias Atlas.Accounts

  def upload_avatar(conn, %{"id" => user_id, "avatar" => upload}) do
    user_id
    |> get_user()
    |> update_user_avatar(upload)
    |> send_upload_response(conn)
  end

  def upload_avatar(conn, %{"id" => _user_id}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", message: "No avatar file provided"})
  end

  defp send_upload_response({:ok, user}, conn) do
    conn
    |> put_status(:ok)
    |> json(%{
      status: "success",
      message: "Avatar uploaded successfully",
      data: %{avatar_url: Accounts.get_user_avatar_url(user), user_id: user.id}
    })
  end

  defp send_upload_response({:error, reason}, conn) do
    {status, message} =
      case reason do
        :not_found -> {:not_found, "User not found"}
        %Ecto.Changeset{} -> {:unprocessable_entity, "Avatar validation failed"}
        _ -> {:unprocessable_entity, "Upload failed"}
      end

    conn |> put_status(status) |> json(%{status: "error", message: message})
  end

  swagger_path :upload_avatar do
    post("/v1/users/{id}/avatar")
    summary("Upload user avatar")
    description("Upload an avatar image for a specific user")
    produces("application/json")
    tag("Uploaders")
    consumes("multipart/form-data")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "User ID", required: true)
      avatar(:formData, :file, "Avatar image file", required: true)
    end

    response(200, "Success", Schema.ref(:AvatarUploadSuccess))
    response(422, "Validation error", Schema.ref(:ErrorResponse))
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

  def delete_avatar(conn, %{"id" => user_id}) do
    user_id
    |> get_user()
    |> remove_user_avatar()
    |> send_delete_response(conn)
  end

  defp remove_user_avatar({:ok, user}) do
    Accounts.remove_user_avatar(user)
  end

  defp remove_user_avatar(error), do: error

  defp send_delete_response({:ok, user}, conn) do
    conn
    |> put_status(:ok)
    |> json(%{
      status: "success",
      message: "Avatar deleted successfully",
      data: %{user_id: user.id}
    })
  end

  defp send_delete_response({:error, reason}, conn) do
    {status, message} =
      case reason do
        %Ecto.Changeset{} -> {:unprocessable_entity, "Avatar deletion failed"}
        _ -> {:unprocessable_entity, "Deletion failed"}
      end

    conn |> put_status(status) |> json(%{status: "error", message: message})
  end

  swagger_path :delete_avatar do
    delete("/v1/users/{id}/avatar")
    summary("Delete user avatar")
    description("Delete the avatar image for a specific user")
    produces("application/json")
    tag("Uploaders")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "User ID", required: true)
    end

    response(200, "Success", Schema.ref(:AvatarDeleteSuccess))
    response(422, "Deletion failed", Schema.ref(:ErrorResponse))
  end

  def swagger_definitions do
    %{
      AvatarUploadSuccess:
        swagger_schema do
          title("Avatar Upload Success Response")
          description("Successful avatar upload response")
          type(:object)

          properties do
            status(:string, "Response status", example: "success")
            message(:string, "Success message", example: "Avatar uploaded successfully")
            data(Schema.ref(:AvatarData))
          end

          required([:status, :message, :data])
        end,
      AvatarData:
        swagger_schema do
          title("Avatar Data")
          description("Avatar upload data")
          type(:object)

          properties do
            avatar_url(:string, "URL of the uploaded avatar",
              example: "/this/is/an/xXxXxXxX-xxxx-xxxx-xxxx-xxxxxxxxxxxx/example.jpg"
            )

            user_id(:string, "User UUID", example: "xXxXxXxX-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
          end

          required([:avatar_url, :user_id])
        end,
      ErrorResponse:
        swagger_schema do
          title("Error Response")
          description("Error response format")
          type(:object)

          properties do
            status(:string, "Response status", example: "error")
            message(:string, "Error message", example: "User not found")
          end

          required([:status, :message])
        end,
      AvatarDeleteSuccess:
        swagger_schema do
          title("Successful Avatar Deletion")
          description("Successful avatar deletion response")
          type(:object)

          properties do
            status(:string, "Response status", example: "success")
            message(:string, "Success message", example: "Avatar deleted successfully")
            data(Schema.ref(:DeleteData))
          end

          required([:status, :message, :data])
        end,
      DeleteData:
        swagger_schema do
          title("Delete Data")
          description("Avatar deletion data")
          type(:object)

          properties do
            user_id(:string, "User UUID", example: "xXxXxXxX-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
          end

          required([:user_id])
        end
    }
  end
end
