defmodule Atlas.Degrees.Degree do
  @moduledoc """
  University degree associated with students.
  """
  use Atlas.Schema

  @required_fields ~w(name code)a

  schema "degrees" do
    field :code, :string
    field :name, :string

    many_to_many :students, Atlas.University.Student,
      join_through: Atlas.University.Enrollment,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(degree, attrs) do
    degree
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :degrees_code_index)
  end
end
