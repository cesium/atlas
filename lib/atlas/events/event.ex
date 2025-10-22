defmodule Atlas.Events.Event do
  @moduledoc """
  Event schema.
  """
  use Atlas.Schema

  @required_fields ~w(title start end category_id)a
  @optional_fields ~w(place link)a

  schema "events" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    field :link, :string
    field :title, :string
    field :place, :string

    belongs_to :category, Atlas.Events.EventCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:category_id)
  end
end
