defmodule Atlas.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :gender, :string
      add :profile_picture, :string
      add :birth_date, :date
      add :is_active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
    create index(:users, [:is_active])
  end
end
