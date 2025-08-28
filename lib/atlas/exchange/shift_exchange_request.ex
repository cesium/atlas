defmodule Atlas.Exchange.ShiftExchangeRequest do
  use Atlas.Schema

  @required_fields ~w(status student_id shift_from shift_to)a

  schema "shift_exchange_requests" do
    field :status, Ecto.Enum, values: ~w(pending approved cancelled)a

    belongs_to :student, Atlas.University.Student

    belongs_to :from, Atlas.University.Shift, foreign_key: :shift_from
    belongs_to :to, Atlas.University.Shift, foreign_key: :shift_to

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift_exchange_request, attrs) do
    shift_exchange_request
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:student_id, :shift_from, :shift_to], name: :unique_shift_exchange_request)
  end
end
