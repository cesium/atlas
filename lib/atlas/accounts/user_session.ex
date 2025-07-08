defmodule Atlas.Accounts.UserSession do
  use Atlas.Schema

  @optional_fields ~w(ip user_agent)a
  @required_fields ~w(user_id)a
  schema "users_sessions" do
    field :ip, :string
    field :user_agent, :string

    belongs_to :user, Atlas.Accounts.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_session, attrs) do
    user_session
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
  end
end
