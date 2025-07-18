defmodule Atlas.Degrees.Degree do
  @moduledoc """
  University degree associated with students.
  """
  use Atlas.Schema

  @required_fields ~w(name code)a
  schema "degrees" do
    field :code, :string
    field :name, :string

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
