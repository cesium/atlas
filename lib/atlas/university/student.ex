defmodule Atlas.University.Student do
  @moduledoc """
  University student.
  """
  use Atlas.Schema

  @required_fields ~w(number degree_id)a
  @optional_fields ~w(special_status degree_year user_id)a

  schema "students" do
    field :number, :string
    field :special_status, :string
    field :degree_year, :integer

    belongs_to :user, Atlas.Accounts.User
    belongs_to :degree, Atlas.Degrees.Degree

    many_to_many :courses, Atlas.Degrees.Course,
      join_through: Atlas.University.Enrollment,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:number, name: :students_number_index)
  end
end
