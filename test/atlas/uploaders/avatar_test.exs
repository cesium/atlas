defmodule Atlas.AvatarTest do
  use AtlasWeb.ConnCase

  alias AtlasWeb.UserController
  alias Atlas.AccountsFixtures

  setup do
    user = AccountsFixtures.user_fixture(%{type: :student})
    conn = authenticated_conn(%{type: :student})

    %{
      user: user,
      conn: conn
    }
  end

  describe "valid avatar upload" do
    test "uploads a valid avatar", %{user: user, conn: conn} do
      upload = %Plug.Upload{
        content_type: "image/png",
        filename: "avatar.png",
        path: "test/support/fixtures/images/avatar.png"
      }

      conn = UserController.upload_avatar(conn, %{"id" => user.id, "avatar" => upload})
      assert conn.status == 200

      assert %{"status" => "success", "message" => "Avatar uploaded successfully"} =
               Jason.decode!(conn.resp_body)
    end
  end

  describe "invalid avatar upload" do
    test "uploads an invalid avatar", %{user: user, conn: conn} do
      upload = %Plug.Upload{
        content_type: "image/gif",
        filename: "avatar.gif",
        path: "test/support/fixtures/images/avatar.gif"
      }

      conn = UserController.upload_avatar(conn, %{"id" => user.id, "avatar" => upload})
      assert conn.status == 422

      assert %{"status" => "error", "message" => "Avatar validation failed"} =
               Jason.decode!(conn.resp_body)
    end
  end
end
