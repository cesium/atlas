defmodule Atlas.Repo.Migrations.AddIsActiveGenderBirthDateToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_active, :boolean, default: true, null: false
      add :gender, :string
      add :birth_date, :date
      add :profile_picture, :string
    end
  end
end
