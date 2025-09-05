defmodule Atlas.Exchange.ShiftExchangeRequest do
  use Atlas.Schema

  @required_fields ~w(status student_id shift_from shift_to)a

  schema "shift_exchange_requests" do
    field :status, Ecto.Enum, values: ~w(pending approved cancelled)a, default: :pending

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
    |> unique_constraint([:student_id, :shift_from, :shift_to],
      name: :unique_shift_exchange_request
    )
  end

  def create_request_changeset(shift_exchange_request, attrs) do
    shift_exchange_request
    |> cast(attrs, [:shift_from, :shift_to, :student_id])
    |> validate_required(@required_fields)
    |> unique_constraint([:student_id, :shift_from, :shift_to],
      name: :unique_shift_exchange_request
    )
    |> validate_same_type_shifts()
    |> validate_different_shifts()
  end

  defp validate_same_type_shifts(changeset) do
    shift_from_id = get_field(changeset, :shift_from)
    shift_to_id = get_field(changeset, :shift_to)

    if shift_from_id && shift_to_id do
      shift_from = Atlas.Repo.get(Atlas.University.Shift, shift_from_id)
      shift_to = Atlas.Repo.get(Atlas.University.Shift, shift_to_id)

      if shift_from && shift_to &&
           (shift_from.course_id != shift_to.course_id || shift_from.type != shift_to.type) do
        add_error(
          changeset,
          :shift_to,
          "Origin shift must be of the same course and type as from shift"
        )
      else
        changeset
      end
    else
      changeset
    end
  end

  defp validate_different_shifts(changeset) do
    shift_from_id = get_field(changeset, :shift_from)
    shift_to_id = get_field(changeset, :shift_to)

    if shift_from_id && shift_to_id && shift_from_id == shift_to_id do
      add_error(changeset, :shift_to, "Origin and destination shifts must be different")
    else
      changeset
    end
  end
end
