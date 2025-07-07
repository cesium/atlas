defmodule Atlas.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :current_password, :string, virtual: true  # Add this line
    field :password_hash, :string
    field :gender, :string
    field :profile_picture, :string
    field :birth_date, :date
    field :is_active, :boolean, default: true

    # Assuming relationship with student
    has_one :student, Atlas.Students.Student

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :gender, :profile_picture, :birth_date])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_inclusion(:gender, ["male", "female", "other", "prefer_not_to_say"])
    |> validate_length(:password, min: 8, max: 128)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc false
  def update_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :current_password])
    |> validate_required([:password, :current_password])
    |> validate_length(:password, min: 8, max: 128)
    |> validate_current_password()
    |> put_password_hash()
  end

  @doc false
  def update_profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:gender, :profile_picture, :birth_date])
    |> validate_inclusion(:gender, ["male", "female", "other", "prefer_not_to_say"])
    |> validate_birth_date()
  end

  @doc false
  def soft_delete_changeset(user) do
    user
    |> change(is_active: false)
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  defp validate_current_password(changeset) do
    case get_change(changeset, :current_password) do
      nil ->
        changeset

      current_password ->
        if Bcrypt.verify_pass(current_password, changeset.data.password_hash) do
          changeset
        else
          add_error(changeset, :current_password, "is invalid")
        end
    end
  end

  defp validate_birth_date(changeset) do
    case get_change(changeset, :birth_date) do
      nil ->
        changeset

      birth_date ->
        today = Date.utc_today()
        min_age_date = Date.add(today, -13 * 365) # Minimum 13 years old
        max_age_date = Date.add(today, -120 * 365) # Maximum 120 years old

        cond do
          Date.compare(birth_date, today) == :gt ->
            add_error(changeset, :birth_date, "cannot be in the future")

          Date.compare(birth_date, min_age_date) == :gt ->
            add_error(changeset, :birth_date, "user must be at least 13 years old")

          Date.compare(birth_date, max_age_date) == :lt ->
            add_error(changeset, :birth_date, "invalid birth date")

          true ->
            changeset
        end
    end
  end
end
