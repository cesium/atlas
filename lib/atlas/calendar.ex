defmodule Atlas.Calendar do
  @moduledoc """
  iCalendar (.ics) file generator for Atlas.
  """

  @prodid "-//Atlas//EN"

  alias Atlas.University.Degrees.Courses.Shifts.Shift

  defp format_datetime(%NaiveDateTime{} = dt) do
    dt
    |> NaiveDateTime.to_iso8601()
    |> String.replace(~r/[-:]/, "")
    |> String.replace(~r/\.\d+Z?/, "")
  end

  @doc """
  Converts a list of shifts into `.ics` calendar content.

  Each shift should be preloaded with :timeslots and :course associations.
  """
  def shifts_to_ics(shifts, opts \\ []) do
    uid_prefix = Keyword.get(opts, :uid_prefix, "atlas")
    cal_name = Keyword.get(opts, :calendar_name, "Atlas Calendar")
    dtstamp = format_datetime(NaiveDateTime.utc_now())

    events =
      shifts
      |> Enum.with_index()
      |> Enum.flat_map(fn {shift, idx} ->
        shift.timeslots
        |> Enum.map(fn ts ->
          uid = "#{uid_prefix}-#{shift_uid(shift, idx)}-#{ts.id || "ts"}"
          {dtstart, dtend} = extract_start_end(ts)

          """
          BEGIN:VEVENT
          UID:#{uid}
          DTSTAMP:#{dtstamp}
          DTSTART:#{format_datetime(dtstart)}
          DTEND:#{format_datetime(dtend)}
          SUMMARY:#{escape_text(build_summary(shift))}
          DESCRIPTION:#{escape_text(build_description(shift, ts))}
          LOCATION:#{escape_text(location_of(ts))}
          RRULE:FREQ=WEEKLY;INTERVAL=1
          END:VEVENT
          """
        end)
      end)
      |> Enum.join("\r\n")

    [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:#{@prodid}",
      "CALSCALE:GREGORIAN",
      "METHOD:PUBLISH",
      "X-WR-CALNAME:#{cal_name}",
      events,
      "END:VCALENDAR"
    ]
    |> Enum.join("\r\n")
  end

  # --- Helpers ---------------------------------------------------------------

  # WIP: This function is a patch for the time being as the module does not allow for proper repetiveness atm
  defp extract_start_end(%{start: start_time, end: end_time, weekday: weekday}) do
    today = Date.utc_today()
    # 1 = Monday ... 7 = Sunday
    today_weekday = Date.day_of_week(today)
    target_weekday = weekday_to_int(weekday)

    # Days until the next occurrence of the weekday
    days_ahead = rem(target_weekday - today_weekday + 7, 7)
    # always next week if today
    days_ahead = if days_ahead == 0, do: 7, else: days_ahead

    event_date = Date.add(today, days_ahead)

    {
      NaiveDateTime.new!(event_date, start_time),
      NaiveDateTime.new!(event_date, end_time)
    }
  end

  defp weekday_to_int(:monday), do: 1
  defp weekday_to_int(:tuesday), do: 2
  defp weekday_to_int(:wednesday), do: 3
  defp weekday_to_int(:thursday), do: 4
  defp weekday_to_int(:friday), do: 5
  defp weekday_to_int(:saturday), do: 6
  defp weekday_to_int(:sunday), do: 7

  defp shift_uid(shift, idx), do: Map.get(shift, :id, idx)

  defp build_summary(shift) do
    course_name =
      if shift.course && shift.course.name do
        shift.course.name
      else
        "Course"
      end

    "#{course_name} – #{Shift.short_name(shift)}"
  end

  defp build_description(shift, ts) do
    {st, en} = extract_start_end(ts)

    time_range =
      "#{String.slice(Time.to_iso8601(NaiveDateTime.to_time(st)), 0, 5)} - " <>
        String.slice(Time.to_iso8601(NaiveDateTime.to_time(en)), 0, 5)

    professor =
      if is_binary(shift.professor), do: shift.professor, else: ""

    """
    Shift #{Shift.short_name(shift)}
    Time: #{time_range}
    Location: #{location_of(ts)}
    Professor: #{professor}
    """
  end

  defp location_of(ts) do
    if ts.building && ts.room do
      "#{ts.building} #{ts.room}"
    else
      "Unspecified location"
    end
  end

  defp escape_text(nil), do: ""

  defp escape_text(text) when is_binary(text) do
    text
    |> String.replace("\r\n", "\\n")
    |> String.replace("\n", "\\n")
    |> String.replace(",", "\\,")
    |> String.replace(";", "\\;")
  end
end
