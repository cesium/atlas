defmodule Atlas.CalendarTest do
  use ExUnit.Case, async: true

  alias Atlas.Calendar
  alias Atlas.Events.Event
  alias Atlas.Events.EventCategory
  alias Atlas.University.Degrees.Courses.Course
  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias Atlas.University.Degrees.Courses.Shifts.Timeslot

  describe "schedule_to_ics/2" do
    test "generates recurring events for shifts and timeslots" do
      timeslot = %Timeslot{
        id: 1,
        weekday: :monday,
        start: ~T[09:00:00],
        end: ~T[11:00:00],
        building: "Ed. 1",
        room: "1.01"
      }

      course = %Course{name: "Sistemas Distribuídos"}

      shift = %Shift{
        id: 42,
        number: 1,
        type: :practical_laboratory,
        professor: "Prof. Alberto",
        course: course,
        timeslots: [timeslot]
      }

      ics = Calendar.schedule_to_ics([shift], calendar_name: "Test Schedule")

      assert String.contains?(ics, "BEGIN:VCALENDAR")
      assert String.contains?(ics, "X-WR-CALNAME:Test Schedule")
      assert String.contains?(ics, "X-WR-TIMEZONE:Europe/Lisbon")
      assert String.contains?(ics, "BEGIN:VTIMEZONE")
      assert String.contains?(ics, "TZID:Europe/Lisbon")
      assert String.contains?(ics, "BEGIN:VEVENT")
      assert String.contains?(ics, "DTSTART;TZID=Europe/Lisbon:")
      assert String.contains?(ics, "DTEND;TZID=Europe/Lisbon:")
      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1")
      assert String.contains?(ics, "SUMMARY:Sistemas Distribuídos – PL1")
      assert String.contains?(ics, "LOCATION:Ed. 1 1.01")
      assert String.contains?(ics, "Professor: Prof. Alberto")
      assert String.contains?(ics, "END:VEVENT")
      assert String.contains?(ics, "END:VCALENDAR")
    end

    test "anchors start date to semester start when start is given without end" do
      timeslot = %Timeslot{
        id: 1,
        weekday: :monday,
        start: ~T[09:00:00],
        end: ~T[11:00:00],
        building: "Ed. 1",
        room: "1.01"
      }

      course = %Course{name: "Sistemas Distribuídos", semester: 1}

      shift = %Shift{
        id: 42,
        number: 1,
        type: :practical_laboratory,
        course: course,
        timeslots: [timeslot]
      }

      period = %{start: ~U[2024-09-16 00:00:00Z], end: nil}

      ics = Calendar.schedule_to_ics([shift], classes_period: period)

      assert String.contains?(ics, "DTSTART;TZID=Europe/Lisbon:20240916T090000")
      assert String.contains?(ics, "DTEND;TZID=Europe/Lisbon:20240916T110000")
      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1\r\n")
    end

    test "adds UNTIL to RRULE when end is given without start" do
      timeslot = %Timeslot{
        id: 1,
        weekday: :wednesday,
        start: ~T[14:00:00],
        end: ~T[16:00:00]
      }

      course = %Course{name: "Sistemas Distribuídos", semester: 1}

      shift = %Shift{
        id: 42,
        number: 1,
        type: :practical_laboratory,
        course: course,
        timeslots: [timeslot]
      }

      period = %{start: nil, end: ~U[2024-12-31 23:59:59Z]}

      ics = Calendar.schedule_to_ics([shift], classes_period: period)

      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20241231T235959Z")
    end

    test "anchors start and sets UNTIL when both start and end are given" do
      timeslot = %Timeslot{
        id: 1,
        weekday: :friday,
        start: ~T[10:00:00],
        end: ~T[12:00:00]
      }

      course = %Course{name: "Algoritmos", semester: 1}

      shift = %Shift{
        id: 10,
        number: 1,
        type: :theoretical_practical,
        course: course,
        timeslots: [timeslot]
      }

      period = %{start: ~D[2024-09-16], end: ~U[2024-12-20 23:59:59Z]}

      ics = Calendar.schedule_to_ics([shift], classes_period: period)

      assert String.contains?(ics, "DTSTART;TZID=Europe/Lisbon:20240920T100000")
      assert String.contains?(ics, "DTEND;TZID=Europe/Lisbon:20240920T120000")
      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20241220T235959Z")
    end

    test "resolves period per course semester using classes_periods map" do
      shift1 = %Shift{
        id: 1,
        number: 1,
        type: :practical_laboratory,
        course: %Course{name: "C1", semester: 1},
        timeslots: [%Timeslot{id: 1, weekday: :monday, start: ~T[08:00:00], end: ~T[10:00:00]}]
      }

      shift2 = %Shift{
        id: 2,
        number: 2,
        type: :practical_laboratory,
        course: %Course{name: "C2", semester: 2},
        timeslots: [%Timeslot{id: 2, weekday: :monday, start: ~T[14:00:00], end: ~T[16:00:00]}]
      }

      periods = %{
        1 => %{start: ~D[2024-09-16], end: ~U[2024-12-20 23:59:59Z]},
        2 => %{start: ~D[2025-02-10], end: ~U[2025-06-06 23:59:59Z]}
      }

      ics = Calendar.schedule_to_ics([shift1, shift2], classes_periods: periods)

      assert String.contains?(ics, "DTSTART;TZID=Europe/Lisbon:20240916T080000")
      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20241220T235959Z")

      assert String.contains?(ics, "DTSTART;TZID=Europe/Lisbon:20250210T140000")
      assert String.contains?(ics, "RRULE:FREQ=WEEKLY;INTERVAL=1;UNTIL=20250606T235959Z")
    end
  end

  describe "events_to_ics/2" do
    test "generates ics for academic events" do
      start_dt = ~U[2026-10-15 14:00:00Z]
      end_dt = ~U[2026-10-15 16:00:00Z]

      course = %Course{name: "Compiladores"}
      category = %EventCategory{name: "Exames", course: course}

      event = %Event{
        id: 10,
        title: "Teste 1",
        start: start_dt,
        end: end_dt,
        place: "Anfiteatro B1",
        link: "https://example.com/exam-info",
        category: category
      }

      ics = Calendar.events_to_ics([event], calendar_name: "Test Events")

      assert String.contains?(ics, "BEGIN:VCALENDAR")
      assert String.contains?(ics, "X-WR-CALNAME:Test Events")
      assert String.contains?(ics, "X-WR-TIMEZONE:Europe/Lisbon")
      assert String.contains?(ics, "BEGIN:VTIMEZONE")
      assert String.contains?(ics, "BEGIN:VEVENT")
      assert String.contains?(ics, "UID:atlas-event-10")
      assert String.contains?(ics, "SUMMARY:Compiladores – Teste 1")
      assert String.contains?(ics, "LOCATION:Anfiteatro B1")
      assert String.contains?(ics, "URL:https://example.com/exam-info")
      assert String.contains?(ics, "Category: Exames")
      assert String.contains?(ics, "DTSTART:20261015T140000Z")
      assert String.contains?(ics, "DTEND:20261015T160000Z")
      assert String.contains?(ics, "END:VEVENT")
      assert String.contains?(ics, "END:VCALENDAR")
    end
  end
end
