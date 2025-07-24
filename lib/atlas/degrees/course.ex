defmodule Atlas.Degrees.Course do
  use Atlas.Schema

  @required_fields ~w(name code year semester degree_id)a
  @optional_fields ~w(parent_course_id)a

  schema "courses" do
    field :name, :string
    field :code, :string
    field :year, :integer
    field :semester, :integer
    field :parent_course_id, :binary_id

    belongs_to :degree, Atlas.Degrees.Degree

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
