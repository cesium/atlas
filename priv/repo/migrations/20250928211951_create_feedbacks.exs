defmodule Atlas.Repo.Migrations.CreateFeedbacks do
  use Ecto.Migration

  def change do
    create table(:feedbacks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string
      add :message, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:feedbacks, [:user_id])
  end
end
