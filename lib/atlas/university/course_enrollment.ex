defmodule Atlas.University.CourseEnrollment do
  @moduledoc """
  Student course enrollment in courses.
  """
  use Atlas.Schema

  @required_fields ~w(student_id course_id)a
  schema "course_enrollments" do
    belongs_to :student, Atlas.University.Student
    belongs_to :course, Atlas.University.Degrees.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course_enrollment, attrs) do
    course_enrollment
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:student_id, :course_id], name: :unique_student_course_enrollment)
  end
end
