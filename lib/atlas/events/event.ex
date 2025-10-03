defmodule Atlas.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :start, :utc_datetime
    field :link, :string
    field :title, :string
    field :end, :utc_datetime
    field :place, :string

    belongs_to :category, Atlas.Events.EventCategory
    belongs_to :course, Atlas.University.Degrees.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :start, :end, :place, :link])
    |> validate_required([:title, :start, :end, :place, :link])
  end
end
