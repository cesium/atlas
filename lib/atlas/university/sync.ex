defmodule Atlas.University.Sync do
  @moduledoc false

  alias Atlas.{Constants, Repo}
  alias Atlas.University.Degrees.Courses.Shifts
  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot
  alias Atlas.University.Telescopium
  alias Atlas.Workers.{LinkTimeslots, SyncTimeslots}

  def queue_link_timeslots(config \\ %{}, user) do
    LinkTimeslots.new(%{"config" => config},
      meta: %{user_id: user.id, type: :scrape_and_link_timeslots}
    )
    |> Oban.insert()
  end

  def link_timeslots_from_parsed(parsed_shifts) do
    run_pipeline(parsed_shifts, &match_by_natural_key/1)
  end

  def queue_sync_timeslots(config \\ %{}, user) do
    SyncTimeslots.new(%{"config" => config},
      meta: %{user_id: user.id, type: :scrape_and_sync_timeslots}
    )
    |> Oban.insert()
  end

  def sync_timeslots_from_parsed(parsed_shifts) do
    run_pipeline(parsed_shifts, &match_by_scraped_id/1)
  end

  defp run_pipeline(parsed_shifts, match_fn) do
    pairs = Enum.map(parsed_shifts, match_fn)
    {matched, unmatched} = Enum.split_with(pairs, fn %{timeslot: t} -> t != nil end)

    case update_pairs(matched) do
      {:ok, count} ->
        {:ok,
         %{
           matched: length(matched),
           updated: count,
           unmatched: Enum.map(unmatched, & &1.scraped_shift)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp match_by_natural_key(%{type: nil, number: nil} = scraped_shift) do
    %{timeslot: nil, scraped_shift: scraped_shift}
  end

  defp match_by_natural_key(scraped_shift) do
    timeslot =
      Shifts.get_timeslot_by_natural_key(
        scraped_shift.course,
        scraped_shift.type,
        scraped_shift.number,
        scraped_shift.start,
        scraped_shift.end,
        scraped_shift.weekday
      )

    %{timeslot: timeslot, scraped_shift: scraped_shift}
  end

  defp match_by_scraped_id(scraped_shift) do
    timeslot =
      Shifts.get_timeslot_by_scraped_id(scraped_shift.id)

    %{timeslot: timeslot, scraped_shift: scraped_shift}
  end

  defp update_pairs(shift_pairs) do
    changesets =
      shift_pairs
      |> Enum.map(fn %{timeslot: timeslot, scraped_shift: scraped_shift} ->
        attrs =
          %{
            scraped_id: scraped_shift.id,
            room: scraped_shift.room,
            building: scraped_shift.building
          }
          |> Map.reject(fn {_, value} -> is_nil(value) or value == "" end)

        Timeslot.changeset(timeslot, attrs)
      end)
      |> Enum.filter(&(&1.changes != %{}))

    changesets
    |> Enum.reduce(Ecto.Multi.new(), fn changeset, multi ->
      Ecto.Multi.update(multi, {:update, changeset.data.id}, changeset)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> {:ok, length(changesets)}
      {:error, _, reason, _changed} -> {:error, reason}
    end
  end

  def fetch_and_parse do
    case Telescopium.fetch_result() do
      {:ok, %{shifts: shifts}} ->
        parsed =
          shifts
          |> Enum.map(fn shift ->
            Map.new(shift, fn {k, v} -> {String.to_existing_atom(k), v} end)
          end)
          |> Enum.map(&parse_scraped_shift/1)

        {:ok, parsed}

      {:ok, %{status: "running"}} ->
        :pending

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_scraped_shift(scraped_shift) do
    %{type: type, number: number} =
      case scraped_shift.shift do
        nil ->
          %{type: nil, number: nil}

        shift ->
          case Shift.parse_short_name(shift) do
            %{type: type, number: number} when not is_nil(type) ->
              %{type: type, number: number}

            _ ->
              %{type: nil, number: nil}
          end
      end

    %{
      id: scraped_shift.id,
      course: scraped_shift.name,
      type: type,
      number: number,
      start: Time.from_iso8601!(scraped_shift.start_time),
      end: Time.from_iso8601!(scraped_shift.end_time),
      weekday: parse_weekday(scraped_shift.weekday),
      building: scraped_shift.location |> Timeslot.parse_building(),
      room: scraped_shift.location |> Timeslot.parse_room()
    }
  end

  defp parse_weekday(weekday) do
    Enum.find(Timeslot.weekdays(), &(Atom.to_string(&1) == weekday))
  end

  def toggle_auto_sync do
    case get_auto_sync_state() do
      {:ok, state} when is_boolean(state) ->
        Constants.set("auto_sync", !state)

      nil ->
        Constants.set("auto_sync", true)

      {:ok, _invalid_state} ->
        {:error, "invalid auto_sync state"}
    end
  end

  def get_auto_sync_state do
    case Constants.get("auto_sync") do
      {:ok, state} ->
        {:ok, state}

      {:error, _} ->
        case Constants.set("auto_sync", false) do
          {:ok, _pair} -> {:ok, false}
          {:error, _reason} -> nil
        end
    end
  end

  def auto_sync_enabled? do
    get_auto_sync_state() == {:ok, true}
  end
end
