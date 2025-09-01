defmodule Atlas.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Atlas.Context

  alias Atlas.Accounts.{User, UserNotifier, UserPreferences, UserSession, UserToken}
  alias Atlas.University.Student

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
  def get_user_by_email(email, opts \\ []) when is_binary(email) do
    User
    |> apply_filters(opts)
    |> Repo.get_by(email: email)
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
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.registration_changeset(%User{}, attrs))
    |> create_default_preferences_multi()
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
      {:error, :preferences, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Registers a student user.

  ## Examples

      iex> register_student_user(%{name: "John Doe", email: "john.doe@example.com"})
      {:ok, %User{}}

      iex> register_student_user(%{name: "John Doe", email: "invalid_email"})
      {:error, %Ecto.Changeset{}}

  """
  def register_student_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user,
      User.registration_changeset(
        %User{},
        attrs |> Map.put(:type, :student) |> Map.delete(:student)
      )
    )
    |> Ecto.Multi.update(
      :confirm_user,
      fn %{user: user} ->
        User.confirm_changeset(user)
      end
    )
    |> Ecto.Multi.insert(:student, fn %{user: user} ->
      Student.changeset(%Student{}, Map.put(attrs.student, :user_id, user.id))
    end)
    |> Repo.transaction()
  end

  @doc """
  Registers a student user with a random password.

  ## Examples

      iex> register_student_user_with_random_password(%{name: "John Doe", email: "john.doe@example.com"})
      {:ok, %User{}}

  """
  def register_student_user_with_random_password(attrs) do
    random_password = :crypto.strong_rand_bytes(12) |> Base.encode64()
    register_student_user(Map.put(attrs, :password, random_password))
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

  ## User Preferences

  @doc """
  Creates a user preference.
  """
  def create_preference(attrs) when is_map(attrs) and map_size(attrs) > 0 do
    %UserPreferences{}
    |> UserPreferences.changeset(attrs)
    |> Repo.insert()
  end

  def create_preference(_), do: {:error, :invalid_fields}

  @doc """
  Updates a user preference.
  """
  def update_preference(%UserPreferences{} = preference, attrs)
      when is_map(attrs) and map_size(attrs) > 0 do
    preference
    |> UserPreferences.changeset(attrs)
    |> Repo.update()
  end

  def update_preference(_, _), do: {:error, :invalid_fields}

  @doc """
  Gets the set of preferences of a given user.

  ## Examples

      iex> get_user_preferences(1)
      %UserPreferences{}

      iex> get_user_preferences(999)
      nil
  """
  def get_user_preferences(user_id) do
    Repo.get_by(UserPreferences, user_id: user_id)
  end

  @doc """
  Gets a given preference from the user preferences.

  ## Examples

      iex> get_user_preference(1, "language")
      "en-US"

      iex> get_user_preference(1, "void")
      nil
  """
  def get_user_preference(user_id, preference) do
    preferences = get_user_preferences(user_id)
    Map.get(preferences, String.to_atom(preference), nil)
  end

  @doc """
  Sets a given preference or preferences for an user.

  ## Examples

      iex> set_user_preference(%{"user_id" => "1", "language" => "en-US"})
      %UserPreferences{}

      iex> set_user_preference(%{"user_id" => "1", "language" => "pt-PT", "invalid_field" => "none"})
      %UserPreferences{}

      iex> set_user_preference(%{"user_id" => "2", "language" => nil})
      {:error, :invalid_fields}

      iex> set_user_preference(%{"user_id" => "2", %{}})
      {:error, :invalid_fields}
  """

  def set_user_preference(%{"user_id" => user_id} = attrs) when is_binary(user_id) do
    ap = get_available_preferences()

    update_fields =
      attrs
      |> Enum.reject(fn {k, v} -> is_nil(v) or k not in ap end)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})

    case get_user_preferences(user_id) do
      nil -> create_preference(update_fields)
      %UserPreferences{} = up -> update_preference(up, update_fields)
    end
  end

  @doc """
  Gets the available user preferences.
  """
  def get_available_preferences, do: ["language"]

  @doc false
  defp create_default_preferences_multi(multi) do
    Ecto.Multi.insert(multi, :preferences, fn %{user: user} ->
      %UserPreferences{user_id: user.id}
      |> UserPreferences.changeset(%{})
    end)
  end
end
