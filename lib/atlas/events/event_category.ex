defmodule Atlas.Events.EventCategory do
  use Atlas.Schema

  @required_fields ~w(name color)a

  @optional_fields ~w(course_id)a

  schema "event_categories" do
    field :name, :string
    field :color, :string

    belongs_to :course, Atlas.University.Degrees.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_category, attrs) do
    event_category
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
