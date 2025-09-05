defmodule Atlas.Repo.Migrations.CreateShiftExchangeRequests do
  use Ecto.Migration

  def change do
    create table(:shift_exchange_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :student_id, references(:students, on_delete: :nothing, type: :binary_id)
      add :shift_from, references(:shifts, on_delete: :nothing, type: :binary_id)
      add :shift_to, references(:shifts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:shift_exchange_requests, [:student_id])
    create index(:shift_exchange_requests, [:shift_from])
    create index(:shift_exchange_requests, [:shift_to])

    create unique_index(:shift_exchange_requests, [:student_id, :shift_from, :shift_to],
             name: :unique_shift_exchange_request
           )
  end
end
