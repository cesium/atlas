defmodule Atlas.Repo.Migrations.CreateUsersPreferences do
  use Ecto.Migration

  def change do
    create table(:users_preferences, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :language, :string

      timestamps(type: :utc_datetime)
    end

    create index(:users_preferences, [:user_id])

    create constraint(:users_preferences, :language_must_be_valid,
             check: "language IN ('pt-PT', 'en-US')"
           )
  end
end
