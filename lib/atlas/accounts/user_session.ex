defmodule Atlas.Accounts.UserSession do
  @moduledoc """
  Represents a user session in the application.
  """
  use Atlas.Schema
  import Ecto.Query
  alias Atlas.Accounts.UserSession

  @optional_fields ~w(ip user_agent user_os user_browser)a
  @required_fields ~w(user_id)a
  schema "users_sessions" do
    field :ip, :string
    field :user_agent, :string
    field :user_os, :string
    field :user_browser, :string

    belongs_to :user, Atlas.Accounts.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_session, attrs) do
    user_session
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end

  @doc """
  Gets all sessions for the given user.
  """
  def by_user_query(user) do
    from s in UserSession, where: s.user_id == ^user.id
  end
end
