defmodule Atlas.University.Degrees.Courses.Shifts.Shift do
  @moduledoc """
  Represents a shift for a course.
  """
  use Atlas.Schema

  @required_fields ~w(type number course_id capacity)a
  @optional_fields ~w(professor)a

  @shift_type_letters %{
    :theoretical => "T",
    :theoretical_practical => "TP",
    :practical_laboratory => "PL",
    :tutorial_guidance => "OT"
  }

  @shift_types Map.new(@shift_type_letters, fn {k, v} -> {v, k} end)

  schema "shifts" do
    field :type, Ecto.Enum,
      values: [:theoretical, :theoretical_practical, :practical_laboratory, :tutorial_guidance]

    field :number, :integer
    field :capacity, :integer
    field :professor, :string

    belongs_to :course, Atlas.University.Degrees.Courses.Course
    has_many :timeslots, Atlas.University.Degrees.Courses.Shifts.Timeslot
    has_many :enrollments, Atlas.University.ShiftEnrollment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:type, :number, :course_id], name: :shifts_type_number_course_id_index)
  end

  def short_name(shift) do
    short_type = short_type(shift)

    "#{short_type}#{shift.number}"
  end

  def parse_short_name(short_name) do
    case Regex.run(~r/^([A-Z]+)(\d+)$/, short_name) do
      [_, type, number] ->
        %{
          type: type_from_short(type),
          number: String.to_integer(number)
        }

      _ ->
        nil
    end
  end

  def short_type(shift) do
    Map.get(@shift_type_letters, shift.type)
  end

  def type_from_short(short) do
    Map.get(@shift_types, short)
  end
end
