defmodule Atlas.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :start, :time
    field :link, :string
    field :title, :string
    field :end, :time
    field :place, :string
    field :category_id, :binary_id
    field :course, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :start, :end, :place, :link])
    |> validate_required([:title, :start, :end, :place, :link])
  end
end
