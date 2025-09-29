defmodule Atlas.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :start, :time
      add :end, :time
      add :place, :string
      add :link, :string
      add :category_id, references(:event_categories, on_delete: :nothing, type: :binary_id)
      add :course, references(:courses, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:category_id])
    create index(:events, [:course])
  end
end
