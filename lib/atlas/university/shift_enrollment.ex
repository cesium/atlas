defmodule Atlas.University.ShiftEnrollment do
  @moduledoc """
  Represents a student's enrollment in a specific shift.
  """
  use Atlas.Schema

  @status ~w(active inactive override)a

  @required_fields ~w(student_id shift_id status)a

  schema "shift_enrollments" do
    field :status, Ecto.Enum, values: @status

    belongs_to :student, Atlas.University.Student
    belongs_to :shift, Atlas.University.Degrees.Courses.Shifts.Shift

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift_enrollment, attrs) do
    shift_enrollment
    |> cast(attrs, @required_fields)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:shift_id)
    |> validate_required(@required_fields)
  end
end
