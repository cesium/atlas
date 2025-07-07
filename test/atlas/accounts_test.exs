defmodule Atlas.AccountsTest do
  use Atlas.DataCase

  alias Atlas.Accounts
  alias Atlas.Accounts.User
  alias Atlas.Repo  # Add this alias

  # Create a test user to work with
  @valid_user_attrs %{
    email: "test@example.com",
    password: "password123",
    gender: "male",
    birth_date: ~D[1990-01-01]
  }

  describe "users" do
    setup do
      {:ok, user} =
        %User{}
        |> User.changeset(@valid_user_attrs)
        |> Repo.insert()

      %{user: user}
    end

    test "get_user!/1 returns the user with given id", %{user: user} do
      assert Accounts.get_user!(user.id).id == user.id
      assert Accounts.get_user!(user.id).email == user.email
    end

    test "get_active_user!/1 returns active user", %{user: user} do
      assert Accounts.get_active_user!(user.id).id == user.id

      # Mark user as inactive and verify get_active_user! raises
      {:ok, _} =
        user
        |> User.soft_delete_changeset()
        |> Repo.update()

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_active_user!(user.id)
      end
    end

    test "authenticate_user/2 with valid credentials", %{user: user} do
      assert {:ok, authenticated_user} = Accounts.authenticate_user("test@example.com", "password123")
      assert authenticated_user.id == user.id
    end

    test "authenticate_user/2 with invalid password" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("test@example.com", "wrongpassword")
    end

    test "authenticate_user/2 with non-existent email" do
      assert {:error, :invalid_credentials} = Accounts.authenticate_user("nonexistent@example.com", "password123")
    end

    test "authenticate_user/2 with inactive user", %{user: user} do
      # Mark user as inactive
      {:ok, _} =
        user
        |> User.soft_delete_changeset()
        |> Repo.update()

      assert {:error, :invalid_credentials} = Accounts.authenticate_user("test@example.com", "password123")
    end

    test "update_user_password/2 with valid data", %{user: user} do
      password_params = %{
        "current_password" => "password123",
        "password" => "newpassword456"
      }

      assert {:ok, _updated_user} = Accounts.update_user_password(user, password_params)
      assert {:ok, _} = Accounts.authenticate_user(user.email, "newpassword456")
      assert {:error, :invalid_credentials} = Accounts.authenticate_user(user.email, "password123")
    end

    test "update_user_password/2 with invalid current password", %{user: user} do
      password_params = %{
        "current_password" => "wrongpassword",
        "password" => "newpassword456"
      }

      assert {:error, changeset} = Accounts.update_user_password(user, password_params)
      assert %{current_password: ["is invalid"]} = errors_on(changeset)
    end

    test "update_user_password/2 with short password", %{user: user} do
      password_params = %{
        "current_password" => "password123",
        "password" => "short"
      }

      assert {:error, changeset} = Accounts.update_user_password(user, password_params)
      assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
    end

    test "update_user_profile/2 with valid data", %{user: user} do
      profile_params = %{
        "gender" => "female",
        "birth_date" => ~D[1992-05-15]
      }

      assert {:ok, updated_user} = Accounts.update_user_profile(user, profile_params)
      assert updated_user.gender == "female"
      assert updated_user.birth_date == ~D[1992-05-15]
    end

    test "update_user_profile/2 with invalid gender", %{user: user} do
      profile_params = %{
        "gender" => "invalid_gender",
        "birth_date" => ~D[1992-05-15]
      }

      assert {:error, changeset} = Accounts.update_user_profile(user, profile_params)
      assert %{gender: ["is invalid"]} = errors_on(changeset)
    end

    test "update_user_profile/2 with future birth date", %{user: user} do
      future_date = Date.add(Date.utc_today(), 365)
      profile_params = %{
        "gender" => "female",
        "birth_date" => future_date
      }

      assert {:error, changeset} = Accounts.update_user_profile(user, profile_params)
      assert %{birth_date: ["cannot be in the future"]} = errors_on(changeset)
    end

    test "update_user_profile/2 with too young birth date", %{user: user} do
      too_young_date = Date.add(Date.utc_today(), -12 * 365)  # ~12 years old
      profile_params = %{
        "gender" => "female",
        "birth_date" => too_young_date
      }

      assert {:error, changeset} = Accounts.update_user_profile(user, profile_params)
      assert %{birth_date: ["user must be at least 13 years old"]} = errors_on(changeset)
    end

    test "delete_user_account/1 soft deletes user", %{user: user} do
      assert {:ok, deleted_user} = Accounts.delete_user_account(user)
      assert deleted_user.is_active == false

      # Verify user still exists but is inactive
      assert Repo.get(User, user.id)
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_active_user!(user.id)
      end
    end
  end
end
