defmodule Atlas.Events.Event do
  use Atlas.Schema

  @required_fields ~w(title start end place link category_id)a

  schema "events" do
    field :start, :utc_datetime
    field :link, :string
    field :title, :string
    field :end, :utc_datetime
    field :place, :string

    belongs_to :category, Atlas.Events.EventCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:category_id)
  end
end
