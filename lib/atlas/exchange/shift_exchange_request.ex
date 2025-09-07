defmodule Atlas.Exchange.ShiftExchangeRequest do
  @moduledoc """
  Schema for shift exchange requests.
  """
  use Atlas.Schema

  alias Atlas.University.Degrees.Courses.Shifts

  @required_fields ~w(status student_id shift_from shift_to)a

  schema "shift_exchange_requests" do
    field :status, Ecto.Enum, values: ~w(pending approved)a, default: :pending

    belongs_to :student, Atlas.University.Student

    belongs_to :from, Shifts.Shift, foreign_key: :shift_from
    belongs_to :to, Shifts.Shift, foreign_key: :shift_to

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shift_exchange_request, attrs) do
    shift_exchange_request
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_same_type_shifts()
    |> validate_different_shifts()
    |> unique_constraint([:student_id, :shift_from, :status],
      name: :unique_shift_exchange_request,
      message: "This request already exists"
    )
  end

  def create_request_changeset(shift_exchange_request, attrs) do
    shift_exchange_request
    |> cast(attrs, [:shift_from, :shift_to, :student_id])
    |> validate_required(@required_fields)
    |> validate_same_type_shifts()
    |> validate_different_shifts()
    |> unique_constraint([:student_id, :shift_from, :status],
      name: :unique_shift_exchange_request,
      message: "This request already exists"
    )
  end

  defp validate_same_type_shifts(changeset) do
    shift_from_id = get_field(changeset, :shift_from)
    shift_to_id = get_field(changeset, :shift_to)

    if shift_from_id && shift_to_id do
      shift_from = Shifts.get_shift!(shift_from_id)
      shift_to = Shifts.get_shift!(shift_to_id)

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
