defmodule Atlas.Events.Event do
  use Atlas.Schema

  @required_fields ~w(title start end place link category_id)a
  @optional_fields ~w(course_id)a

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
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
