defmodule Atlas.Repo.Migrations.CreateUserPreferences do
  use Ecto.Migration

  def change do
    create table(:user_preferences) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :language, :string, null: false

      timestamps()
    end

    create unique_index(:user_preferences, [:user_id])

    create constraint(:user_preferences, :language_must_be_valid,
      check: "language IN ('pt-PT', 'en-US')"
    )
  end
end
