defmodule Atlas.Accounts.UserPreference do
  @moduledoc """
  Schema for storing a user's preference.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @languages ~w(pt-PT en-US)

  schema "user_preferences" do
    field :language, :string

    belongs_to :user, Atlas.Accounts.User, type: :binary_id

    timestamps()
  end

  def changeset(user_preference, attrs) do
    user_preference
    |> cast(attrs, [:user_id, :language])
    |> validate_required([:user_id, :language])
    |> validate_inclusion(:language, @languages)
    |> assoc_constraint(:user)
    |> unique_constraint(:user_id)
  end
end
