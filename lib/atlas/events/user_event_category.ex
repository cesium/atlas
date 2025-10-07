defmodule Atlas.Events.UserEventCategory do
  use Atlas.Schema

  @required_fields ~w(user_id event_category_id)a

  schema "users_event_categories" do
    belongs_to :user, Atlas.Accounts.User
    belongs_to :event_category, Atlas.Events.EventCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_event_category, attrs) do
    user_event_category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
