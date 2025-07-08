defmodule Atlas.Repo.Migrations.CreateUsersSessions do
  use Ecto.Migration

  def change do
    create table(:users_sessions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ip, :string
      add :user_agent, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:users_sessions, [:user_id])
  end
end
