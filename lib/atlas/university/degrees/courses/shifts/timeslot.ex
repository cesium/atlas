defmodule Atlas.University.Degrees.Courses.Shifts.Timeslot do
  @moduledoc """
  Represents a timeslot for a shift.
  """
  use Atlas.Schema

  @weekdays ~w(monday tuesday wednesday thursday friday saturday sunday)a

  @required_fields ~w(start end weekday shift_id)a

  @optional_fields ~w(building room scraped_id)a

  schema "timeslots" do
    field :start, :time
    field :end, :time
    field :weekday, Ecto.Enum, values: @weekdays
    field :building, :string
    field :room, :string
    field :scraped_id, :binary_id

    belongs_to :shift, Atlas.University.Degrees.Courses.Shifts.Shift

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(timeslot, attrs) do
    timeslot
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def weekdays do
    @weekdays
  end

  def parse_building(location) do
    case location do
      "" ->
        nil

      location ->
        location
        |> String.split("-")
        |> Enum.at(1)
        |> String.trim()
        |> String.split()
        |> Enum.at(1)
    end
  end

  def parse_room(location) do
    case location do
      "" ->
        nil

      location ->
        location
        |> String.split("-")
        |> Enum.at(2)
        |> String.trim()
    end
  end
end
