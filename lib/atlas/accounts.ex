defmodule Atlas.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Atlas.Context

  alias Atlas.Accounts.{User, UserNotifier, UserPreference, UserSession, UserToken}

  ## Database getters

  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id) do
    User
    |> Repo.get(id)
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Ecto.Multi.delete_all(:sessions, UserSession.by_user_query(user))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns the list of users_sessions.

  ## Examples

      iex> list_users_sessions()
      [%UserSession{}, ...]

  """
  def list_users_sessions do
    Repo.all(UserSession)
  end

  @doc """
  Returns the list of user sessions for a specific user.

  ## Examples

      iex> list_user_sessions(123)
      [%UserSession{}, ...]

  """
  def list_user_sessions(user_id) do
    UserSession
    |> where([us], us.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single user_session.

  Raises `Ecto.NoResultsError` if the User session does not exist.

  ## Examples

      iex> get_user_session!(123)
      %UserSession{}

      iex> get_user_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_session!(id), do: Repo.get!(UserSession, id)

  @doc """
  Gets a single user_session.

  Returns `nil` if the User session does not exist.

  ## Examples

      iex> get_user_session(123)
      %UserSession{}

      iex> get_user_session(456)
      nil

  """
  def get_user_session(id) do
    UserSession
    |> preload(:user)
    |> Repo.get(id)
  end

  @doc """
  Updates a user_session.

  ## Examples

      iex> update_user_session(user_session, %{field: new_value})
      {:ok, %UserSession{}}

      iex> update_user_session(user_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_session(%UserSession{} = user_session, attrs) do
    user_session
    |> UserSession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_session changes.

  ## Examples

      iex> change_user_session(user_session)
      %Ecto.Changeset{data: %UserSession{}}

  """
  def change_user_session(%UserSession{} = user_session, attrs \\ %{}) do
    UserSession.changeset(user_session, attrs)
  end

  @doc """
  Creates a user_session.

  ## Examples

      iex> create_user_session(%User{}, %{field: value})
      {:ok, %UserSession{}}

      iex> create_user_session(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_session(
        %User{} = user,
        ip \\ "",
        user_agent \\ "",
        user_os \\ "",
        user_browser \\ ""
      ) do
    %UserSession{}
    |> UserSession.changeset(%{
      user_id: user.id,
      ip: ip,
      user_agent: user_agent,
      user_os: user_os,
      user_browser: user_browser
    })
    |> Repo.insert()
  end

  @doc """
  Deletes a user_session (also deletes corresponding tokens).

  ## Examples

      iex> delete_user_session(user_session)
      {:ok, %UserSession{}}

      iex> delete_user_session(user_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_session(%UserSession{} = user_session) do
    Guardian.DB.revoke_all(user_session.id)
    Repo.delete(user_session)
  end

  ## User Preference

  @doc """
  Gets the language preference for a given user.

  ## Examples

      iex> get_user_preference(1)
      %UserPreference{}

      iex> get_user_preference(999)
      nil
  """
  def get_user_preference(user_id) do
    Repo.get_by(UserPreference, user_id: user_id)
  end

  @doc """
  Sets the language preference for a given user.

  If the preference exists, it replaces it.

  ## Examples

      iex> set_user_language(1, "pt-PT")
      {:ok, %UserPreference{}}

      iex> set_user_language(1, "invalid")
      {:error, %Ecto.Changeset{}}
  """
  def set_user_language(user_id, language) do
    %UserPreference{}
    |> UserPreference.changeset(%{user_id: user_id, language: language})
    |> Repo.insert(
      on_conflict: :replace_all,
      conflict_target: :user_id
    )
  end
end
