defmodule Atlas.Repo.Migrations.CreateShifts do
  use Ecto.Migration

  def change do
    create table(:shifts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :number, :integer
      add :capacity, :integer
      add :professor, :string
      add :course_id, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shifts, [:course_id])
    create unique_index(:shifts, [:type, :number, :course_id], name: :shifts_type_number_course_id_index)
  end
end
