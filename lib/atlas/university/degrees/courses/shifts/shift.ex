defmodule Atlas.University.Degrees.Courses.Shifts.Shift do
  @moduledoc """
  Represents a shift for a course.
  """
  use Atlas.Schema

  @required_fields ~w(type number course_id capacity)a
  @optional_fields ~w(professor)a

  schema "shifts" do
    field :type, Ecto.Enum,
      values: [:theoretical, :theoretical_practical, :practical_laboratory, :tutorial_guidance]

    field :number, :integer
    field :capacity, :integer
    field :professor, :string

    belongs_to :course, Atlas.University.Degrees.Courses.Course
    has_many :timeslots, Atlas.University.Degrees.Courses.Shifts.Timeslot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:type, :number, :course_id], name: :shifts_type_number_course_id_index)
  end
end
