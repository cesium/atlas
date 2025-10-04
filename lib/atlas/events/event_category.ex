defmodule Atlas.Events.EventCategory do
  use Atlas.Schema

  @required_fields ~w(name color)a

  schema "event_categories" do
    field :name, :string
    field :color, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_category, attrs) do
    event_category
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
