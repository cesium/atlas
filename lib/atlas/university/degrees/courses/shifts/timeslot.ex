defmodule Atlas.University.Degrees.Courses.Shifts.Timeslot do
  @moduledoc """
  Represents a timeslot for a shift.
  """
  use Atlas.Schema

  @weekdays ~w(monday tuesday wednesday thursday friday saturday sunday)a

  @required_fields ~w(start end weekday building room shift_id)a

  schema "timeslots" do
    field :start, :time
    field :end, :time
    field :weekday, Ecto.Enum, values: @weekdays
    field :building, :string
    field :room, :string

    belongs_to :shift, Atlas.University.Degrees.Courses.Shifts.Shift

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(timeslot, attrs) do
    timeslot
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def weekdays do
    @weekdays
  end
end
