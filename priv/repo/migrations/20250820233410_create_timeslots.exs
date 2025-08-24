defmodule Atlas.Repo.Migrations.CreateTimeslots do
  use Ecto.Migration

  def change do
    create table(:timeslots, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start, :time
      add :end, :time
      add :weekday, :string
      add :building, :string
      add :room, :string
      add :shift_id, references(:shifts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:timeslots, [:shift_id])
  end
end
