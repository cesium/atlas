defmodule Atlas.Events.EventCategory do
  @moduledoc """
  Event category schema.
  """
  use Atlas.Schema

  @types ~w(optional mandatory)a

  @required_fields ~w(name color type)a
  @optional_fields ~w(course_id)a

  schema "event_categories" do
    field :name, :string
    field :color, :string
    field :type, Ecto.Enum, values: @types

    belongs_to :course, Atlas.University.Degrees.Courses.Course

    has_many :users_event_categories, Atlas.Events.UserEventCategory

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_category, attrs) do
    event_category
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_format(:color, ~r/^#[0-9a-fA-F]{6}$/,
      message: "Invalid color format!(e.g., #RRGGBB)"
    )
    |> validate_required(@required_fields)
  end
end
