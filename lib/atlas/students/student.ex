defmodule Atlas.Students.Student do
  use Ecto.Schema

  @moduledoc """
  Schema for students, representing a student entity in the system.
  """

  schema "students" do
    field :name, :string

    belongs_to :user, Atlas.Accounts.User

    timestamps()
  end
end
