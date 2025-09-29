defmodule Atlas.Events.EventCategory do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_categories" do
    field :name, :string
    field :color, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_category, attrs) do
    event_category
    |> cast(attrs, [:name, :color])
    |> validate_required([:name, :color])
  end
end
