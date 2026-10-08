defmodule Atlas.Repo.Migrations.CreateEventCategories do
  use Ecto.Migration

  def change do
    create table(:event_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color, :string
      add :type, :string
      add :course_id, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:event_categories, [:course_id])
  end
end
