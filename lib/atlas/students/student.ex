defmodule Atlas.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :name, :string

    belongs_to :user, Atlas.Accounts.User

    timestamps()
  end
end
