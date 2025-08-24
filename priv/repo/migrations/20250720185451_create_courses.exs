defmodule Atlas.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :name, :string
      add :shortname, :string
      add :year, :integer
      add :semester, :integer
      add :degree_id, references(:degrees, on_delete: :nothing, type: :binary_id)
      add :parent_course_id, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:courses, [:degree_id])
    create index(:courses, [:parent_course_id])
    create index(:courses, [:code])
    create unique_index(:courses, [:code, :year, :semester])
  end
end
