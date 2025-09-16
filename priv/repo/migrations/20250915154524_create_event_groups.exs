defmodule Atlas.Repo.Migrations.CreateEventGroups do
  use Ecto.Migration

  def change do
    create table(:event_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :foreground_color, :string
      add :background_color, :string
      add :course_id, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:event_groups, [:course_id])
  end
end
