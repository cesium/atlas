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
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:course_id)
  end
end
