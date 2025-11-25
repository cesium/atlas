defmodule Atlas.Repo.Migrations.CreateUsersEventCategories do
  use Ecto.Migration

  def change do
    create table(:users_event_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :event_category_id, references(:event_categories, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:users_event_categories, [:user_id])
    create index(:users_event_categories, [:event_category_id])
  end
end
