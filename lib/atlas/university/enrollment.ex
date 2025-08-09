defmodule Atlas.University.Enrollment do
  @moduledoc """
  Student enrollment in courses.
  """
  use Atlas.Schema

  @required_fields ~w(student_id course_id)a
  schema "enrollments" do
    belongs_to :student, Atlas.University.Student
    belongs_to :course, Atlas.Degrees.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:student_id, :course_id], name: :unique_student_course_enrollment)
  end
end
