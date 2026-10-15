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

  def parse_building(location) when is_binary(location) do
    case String.split(location, "-") do
      [_, part | _] ->
        case String.split(part) do
          [_, building | _] -> building
          _ -> nil
        end

      _ ->
        nil
    end
  end

  def parse_building(_), do: nil

  def parse_room(location) when is_binary(location) do
    case String.split(location, "-") do
      [_, _, room | _] -> String.trim(room)
      _ -> nil
    end
  end

  def parse_room(_), do: nil
end
