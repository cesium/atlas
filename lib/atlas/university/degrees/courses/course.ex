defmodule Atlas.University.Degrees.Courses.Course do
  @moduledoc """
  Courses offered in a degree program.
  """
  use Atlas.Schema

  @required_fields ~w(name code year semester)a
  @optional_fields ~w(parent_course_id degree_id shortname)a

  schema "courses" do
    field :name, :string
    field :shortname, :string
    field :code, :string
    field :year, :integer
    field :semester, :integer

    belongs_to :course, Atlas.University.Degrees.Courses.Course, foreign_key: :parent_course_id

    belongs_to :degree, Atlas.University.Degrees.Degree

    many_to_many :students, Atlas.University.Student,
      join_through: Atlas.University.CourseEnrollment,
      on_replace: :delete

    has_many :shifts, Atlas.University.Degrees.Courses.Shifts.Shift

    has_many :courses, Atlas.University.Degrees.Courses.Course, foreign_key: :parent_course_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :courses_code_year_semester_index)
  end
end
