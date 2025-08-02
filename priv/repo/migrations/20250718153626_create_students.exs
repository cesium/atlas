defmodule Atlas.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :number, :string
      add :special_status, :string
      add :degree_year, :integer
      add :degree_id, references(:degrees, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:students, [:degree_id])
    create index(:students, [:user_id])
    create unique_index(:students, [:number], name: :students_number_index)
  end
end
