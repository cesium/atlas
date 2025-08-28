defmodule Atlas.Accounts.UserPreference do
  @moduledoc """
  Schema for storing a user's preference.
  """

  use Atlas.Schema

  @languages ~w(pt-PT en-US)
  @optional_fields ~w(language)a
  @required_fields ~w(user_id)a

  schema "user_preferences" do
    field :language, :string

    belongs_to :user, Atlas.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(user_preference, attrs) do
    user_preference
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:language, @languages)
  end
end
