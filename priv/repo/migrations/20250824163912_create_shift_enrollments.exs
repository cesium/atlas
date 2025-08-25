defmodule Atlas.Repo.Migrations.CreateShiftEnrollments do
  use Ecto.Migration

  def change do
    create table(:shift_enrollments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, null: false
      add :student_id, references(:students, on_delete: :nothing, type: :binary_id)
      add :shift_id, references(:shifts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shift_enrollments, [:student_id])
    create index(:shift_enrollments, [:shift_id])
  end
end
