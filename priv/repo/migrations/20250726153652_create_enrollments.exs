defmodule Atlas.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :student_id, references(:students, on_delete: :nothing, type: :binary_id)
      add :course_id, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:enrollments, [:student_id])
    create index(:enrollments, [:course_id])

    create unique_index(:enrollments, [:student_id, :course_id],
             name: :unique_student_course_enrollment
           )
  end
end
