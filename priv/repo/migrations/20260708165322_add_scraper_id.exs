defmodule Atlas.Repo.Migrations.ModifyTimeSlots do
  use Ecto.Migration

  def change do
    alter table(:timeslots) do
      add :scraped_id, :binary_id
    end
  end
end
