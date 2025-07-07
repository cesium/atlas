defmodule Atlas.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Atlas.Repo
  alias Atlas.Accounts.User

  @doc """
  Gets a single user by id.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single active user by id.
  """
  def get_active_user!(id) do
    User
    |> where([u], u.id == ^id and u.is_active == true)
    |> Repo.one!()
  end

  @doc """
  Updates user password.
  """
  def update_user_password(user, password_params) do
    user
    |> User.update_password_changeset(password_params)
    |> Repo.update()
  end

  @doc """
  Updates user profile information.
  """
  def update_user_profile(user, profile_params) do
    user
    |> User.update_profile_changeset(profile_params)
    |> Repo.update()
  end

  @doc """
  Soft deletes a user account while preserving student data.
  """
  def delete_user_account(user) do
    user
    |> User.soft_delete_changeset()
    |> Repo.update()
  end

  @doc """
  Authenticates a user with email and password.
  """
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email, is_active: true)

    case user do
      nil ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
