defmodule Atlas.Events.EventGroup do
  use Atlas.Schema

  alias Atlas.University.Degrees.Courses.Course

  @required_fields ~w(name)
  @optional_fields ~w(foreground_color background_color course_id)

  schema "event_groups" do
    field :name, :string
    field :foreground_color, :string
    field :background_color, :string

    belongs_to :course, Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_group, attrs) do
    event_group
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
