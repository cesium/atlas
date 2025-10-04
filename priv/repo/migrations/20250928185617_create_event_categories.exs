defmodule Atlas.Repo.Migrations.CreateEventCategories do
  use Ecto.Migration

  def change do
    create table(:event_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :color, :string

      timestamps(type: :utc_datetime)
    end
  end
end
