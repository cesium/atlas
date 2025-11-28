defmodule Atlas.Repo.Migrations.ModifyEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :category_id,
             references(:event_categories, on_delete: :delete_all, type: :binary_id),
             from: references(:event_categories, on_delete: :nothing, type: :binary_id)
    end

    alter table(:users_event_categories) do
      modify :event_category_id,
             references(:event_categories, on_delete: :delete_all, type: :binary_id),
             from: references(:event_categories, on_delete: :nothing, type: :binary_id)
    end
  end
end
