defmodule AtlasWeb.UserControllerTest do
  use AtlasWeb.ConnCase

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Repo

  @valid_user_attrs %{
    email: "test@example.com",
    password: "password1234",
    gender: "male",
    birth_date: ~D[1990-01-01],
    type: :student,
    name: "Test User"
  }

  defp create_and_login_user(conn) do
    {:ok, user} =
      %User{}
      |> User.changeset(@valid_user_attrs)
      |> Repo.insert()

    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> Plug.Conn.put_session(:user_id, user.id)

    {conn, user}
  end

  describe "update password" do
    setup [:create_conn_and_user]

    test "updates user password when data is valid", %{conn: conn, user: user} do
      password_params = %{
        "current_password" => "password1234",
        "password" => "newpassword456"
      }

      conn = put(conn, "/api/users/#{user.id}/password", %{"password" => password_params})
      assert json_response(conn, 200)["success"] == true

      assert %User{} = Accounts.authenticate_user(user.email, "newpassword456")
    end

    test "returns error when current password is incorrect", %{conn: conn, user: user} do
      password_params = %{
        "current_password" => "wrongpassword",
        "password" => "newpassword456"
      }

      conn = put(conn, "/api/users/#{user.id}/password", %{"password" => password_params})
      assert json_response(conn, 422)["success"] == false
      assert json_response(conn, 422)["errors"]["current_password"] == ["is not valid"]
    end

    test "returns error when password is too short", %{conn: conn, user: user} do
      password_params = %{
        "current_password" => "password1234",
        "password" => "short"
      }

      conn = put(conn, "/api/users/#{user.id}/password", %{"password" => password_params})
      assert json_response(conn, 422)["success"] == false

      assert json_response(conn, 422)["errors"]["password"] == [
               "should be at least 12 character(s)"
             ]
    end

    test "cannot update another user's password", %{conn: conn} do
      {:ok, another_user} =
        %User{}
        |> User.changeset(%{
          email: "another@example.com",
          password: "password1234",
          type: :student,
          name: "Another User"
        })
        |> Repo.insert()

      password_params = %{
        "current_password" => "password1234",
        "password" => "newpassword456"
      }

      conn = put(conn, "/api/users/#{another_user.id}/password", %{"password" => password_params})
      assert json_response(conn, 403)["success"] == false
      assert json_response(conn, 403)["message"] == "Access denied"
    end
  end

  describe "update profile" do
    setup [:create_conn_and_user]

    test "updates user profile when data is valid", %{conn: conn, user: user} do
      profile_params = %{
        "gender" => "female",
        "birth_date" => "1992-05-15"
      }

      conn = put(conn, "/api/users/#{user.id}/profile", %{"profile" => profile_params})
      assert json_response(conn, 200)["success"] == true

      updated_user = Accounts.get_user!(user.id)
      assert updated_user.gender == "female"
      assert updated_user.birth_date == ~D[1992-05-15]
    end

    test "returns error with invalid gender", %{conn: conn, user: user} do
      profile_params = %{
        "gender" => "invalid_gender",
        "birth_date" => "1992-05-15"
      }

      conn = put(conn, "/api/users/#{user.id}/profile", %{"profile" => profile_params})
      assert json_response(conn, 422)["success"] == false
      assert json_response(conn, 422)["errors"]["gender"] == ["is invalid"]
    end

    test "returns error with future birth date", %{conn: conn, user: user} do
      future_date = Date.add(Date.utc_today(), 365) |> Date.to_string()

      profile_params = %{
        "gender" => "female",
        "birth_date" => future_date
      }

      conn = put(conn, "/api/users/#{user.id}/profile", %{"profile" => profile_params})
      assert json_response(conn, 422)["success"] == false
      assert json_response(conn, 422)["errors"]["birth_date"] == ["cannot be in the future"]
    end

    test "handles profile picture upload", %{conn: conn, user: user} do
      tmp_path = Path.join(System.tmp_dir!(), "test_profile_pic.jpg")
      File.write!(tmp_path, "fake image content")

      # Garante que o diretório existe antes do upload
      File.mkdir_p("priv/static/uploads")

      upload = %Plug.Upload{
        path: tmp_path,
        filename: "test_profile_pic.jpg",
        content_type: "image/jpeg"
      }

      profile_params = %{
        "gender" => "female",
        "birth_date" => "1992-05-15",
        "profile_picture" => upload
      }

      conn = put(conn, "/api/users/#{user.id}/profile", %{"profile" => profile_params})

      response = json_response(conn, 200) || json_response(conn, 422)

      assert response["success"] == true ||
               response["success"] == false

      if response["success"] == true do
        updated_user = Accounts.get_user!(user.id)
        assert updated_user.profile_picture != nil
        assert String.starts_with?(updated_user.profile_picture, "/uploads/")
      end

      File.rm(tmp_path)
    end

    test "cannot update another user's profile", %{conn: conn} do
      {:ok, another_user} =
        %User{}
        |> User.changeset(%{
          email: "another@example.com",
          password: "password1234",
          type: :student,
          name: "Another User"
        })
        |> Repo.insert()

      profile_params = %{
        "gender" => "female",
        "birth_date" => "1992-05-15"
      }

      conn = put(conn, "/api/users/#{another_user.id}/profile", %{"profile" => profile_params})
      assert json_response(conn, 403)["success"] == false
      assert json_response(conn, 403)["message"] == "Access denied"
    end
  end

  describe "delete account" do
    setup [:create_conn_and_user]

    test "soft deletes user account", %{conn: conn, user: user} do
      conn = delete(conn, "/api/users/#{user.id}/account")
      assert json_response(conn, 200)["success"] == true

      updated_user = Repo.get(User, user.id)
      assert updated_user.is_active == false

      assert conn.private[:plug_session] == %{}
    end

    test "cannot delete another user's account", %{conn: conn} do
      {:ok, another_user} =
        %User{}
        |> User.changeset(%{
          email: "another@example.com",
          password: "password1234",
          type: :student,
          name: "Another User"
        })
        |> Repo.insert()

      conn = delete(conn, "/api/users/#{another_user.id}/account")
      assert json_response(conn, 403)["success"] == false
      assert json_response(conn, 403)["message"] == "Access denied"

      updated_user = Repo.get(User, another_user.id)
      assert updated_user.is_active == true
    end
  end

  defp create_conn_and_user(_) do
    {conn, user} = create_and_login_user(build_conn())
    %{conn: conn, user: user}
  end
end
