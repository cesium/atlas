defmodule Atlas.Calendar do
  @moduledoc "Minimal iCalendar (.ics) generator"

  alias Atlas.University
  alias Atlas.University.Degrees.Courses.Shifts.Shift

  @timezone "Europe/Lisbon"

  @weekday_numbers %{
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7
  }

  @vtimezone Enum.join(
               [
                 "BEGIN:VTIMEZONE",
                 "TZID:#{@timezone}",
                 "BEGIN:STANDARD",
                 "TZOFFSETFROM:+0100",
                 "TZOFFSETTO:+0000",
                 "TZNAME:WET",
                 "DTSTART:19701025T020000",
                 "RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU",
                 "END:STANDARD",
                 "BEGIN:DAYLIGHT",
                 "TZOFFSETFROM:+0000",
                 "TZOFFSETTO:+0100",
                 "TZNAME:WEST",
                 "DTSTART:19700329T010000",
                 "RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU",
                 "END:DAYLIGHT",
                 "END:VTIMEZONE"
               ],
               "\r\n"
             )

  def schedule_to_ics(shifts, opts \\ []) do
    uid_prefix = Keyword.get(opts, :uid_prefix, "atlas")
    calendar_name = Keyword.get(opts, :calendar_name, "Atlas Schedule")

    shifts
    |> Enum.with_index()
    |> Enum.flat_map(fn {shift, index} ->
      period = resolve_classes_period(shift, opts)
      period_start = period && to_date(period.start)
      period_end = period && to_date(period.end)
      shift_name = Shift.short_name(shift)
      course_name = (shift.course && shift.course.name) || "Course"
      professor = if is_binary(shift.professor), do: shift.professor, else: ""

      Enum.map(shift.timeslots, fn timeslot ->
        date = first_date_on_weekday(timeslot.weekday, period_start || Date.utc_today())
        location = build_location(timeslot)

        description =
          Enum.join(
            [
              "Shift #{shift_name}",
              "Time: #{format_hhmm(timeslot.start)} - #{format_hhmm(timeslot.end)}",
              "Location: #{location || "Unspecified location"}",
              "Professor: #{professor}"
            ],
            "\n"
          )

        uid = "#{uid_prefix}-shift-#{Map.get(shift, :id, index)}-#{timeslot.id || "ts"}"

        build_vevent(uid, [
          "DTSTART;TZID=#{@timezone}:#{format_local(date, timeslot.start)}",
          "DTEND;TZID=#{@timezone}:#{format_local(date, timeslot.end)}",
          "SUMMARY:#{escape_text("#{course_name} – #{shift_name}")}",
          optional_property("DESCRIPTION", description),
          optional_property("LOCATION", location),
          weekly_rrule(period_end)
        ])
      end)
    end)
    |> wrap_calendar(calendar_name, [@vtimezone])
  end

  def events_to_ics(events, opts \\ []) do
    uid_prefix = Keyword.get(opts, :uid_prefix, "atlas")
    calendar_name = Keyword.get(opts, :calendar_name, "Atlas Calendar")

    events
    |> Enum.with_index()
    |> Enum.map(fn {event, index} ->
      build_vevent("#{uid_prefix}-event-#{event.id || index}", [
        "DTSTART:#{format_utc(event.start)}",
        "DTEND:#{format_utc(event.end || event.start)}",
        "SUMMARY:#{escape_text(event_summary(event))}",
        optional_property("DESCRIPTION", event_description(event)),
        optional_property("LOCATION", event.place),
        optional_property("URL", event.link)
      ])
    end)
    |> wrap_calendar(calendar_name, [])
  end

  defp wrap_calendar(event_blocks, calendar_name, extra_components) do
    ([
       "BEGIN:VCALENDAR",
       "VERSION:2.0",
       "PRODID:-//Atlas//EN",
       "CALSCALE:GREGORIAN",
       "METHOD:PUBLISH",
       "X-WR-CALNAME:#{escape_text(calendar_name)}",
       "X-WR-TIMEZONE:#{@timezone}"
     ] ++ extra_components ++ List.flatten(event_blocks) ++ ["END:VCALENDAR"])
    |> Enum.join("\r\n")
  end

  defp build_vevent(uid, properties) do
    (["BEGIN:VEVENT", "UID:#{uid}", "DTSTAMP:#{format_utc(DateTime.utc_now())}"] ++
       properties ++ ["END:VEVENT"])
    |> Enum.filter(& &1)
  end

  defp optional_property(name, value) do
    case value |> to_string() |> String.trim() do
      "" -> nil
      _ -> "#{name}:#{escape_text(value)}"
    end
  end

  defp weekly_rrule(nil), do: "RRULE:FREQ=WEEKLY"

  defp weekly_rrule(period_end) do
    "RRULE:FREQ=WEEKLY;UNTIL=#{Calendar.strftime(period_end, "%Y%m%d")}T235959Z"
  end

  defp resolve_classes_period(shift, opts) do
    semester = shift.course && shift.course.semester

    cond do
      period = opts[:classes_period] -> period
      periods = opts[:classes_periods] -> periods[semester]
      semester in [1, 2] -> University.get_classes_period(semester)
      true -> nil
    end
  end

  defp first_date_on_weekday(weekday, from) do
    days_ahead = rem(@weekday_numbers[weekday] - Date.day_of_week(from) + 7, 7)
    Date.add(from, days_ahead)
  end

  defp to_date(%Date{} = date), do: date
  defp to_date(%DateTime{} = datetime), do: DateTime.to_date(datetime)
  defp to_date(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_date(datetime)

  defp to_date(string) when is_binary(string),
    do: string |> String.slice(0, 10) |> Date.from_iso8601!()

  defp to_date(_), do: nil

  defp format_local(date, time),
    do: Calendar.strftime(NaiveDateTime.new!(date, time), "%Y%m%dT%H%M%S")

  defp format_hhmm(time), do: time |> Time.to_iso8601() |> String.slice(0, 5)

  defp format_utc(%NaiveDateTime{} = datetime),
    do: Calendar.strftime(datetime, "%Y%m%dT%H%M%SZ")

  defp format_utc(%DateTime{} = datetime),
    do: datetime |> DateTime.shift_zone!("Etc/UTC") |> Calendar.strftime("%Y%m%dT%H%M%SZ")

  defp escape_text(nil), do: ""

  defp escape_text(text) do
    text
    |> to_string()
    |> String.replace("\\", "\\\\")
    |> String.replace("\r\n", "\\n")
    |> String.replace("\n", "\\n")
    |> String.replace(",", "\\,")
    |> String.replace(";", "\\;")
  end

  defp build_location(%{building: building, room: room})
       when not is_nil(building) and not is_nil(room),
       do: "#{building} #{room}"

  defp build_location(_timeslot), do: nil

  defp event_summary(event) do
    case event.category && event.category.course do
      %{name: name} when is_binary(name) -> "#{name} – #{event.title}"
      _ -> event.title || "Event"
    end
  end

  defp event_description(event) do
    [
      event.category && event.category.name && "Category: #{event.category.name}",
      event.link && event.link != "" && "Link: #{event.link}"
    ]
    |> Enum.filter(& &1)
    |> Enum.join("\n")
  end
end
