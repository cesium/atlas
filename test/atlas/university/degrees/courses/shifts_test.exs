defmodule Atlas.University.Degrees.Courses.ShiftsTest do
  use Atlas.DataCase

  alias Atlas.DegreesFixtures
  alias Atlas.University.Degrees.Courses
  alias Atlas.University.Degrees.Courses.Shifts

  describe "shifts" do
    alias Atlas.University.Degrees.Courses.Shifts.Shift

    import Atlas.University.Degrees.Courses.ShiftsFixtures

    @invalid_attrs %{type: nil, number: nil, capacity: nil, professor: nil}

    test "list_shifts/0 returns all shifts" do
      shift = shift_fixture()
      assert Shifts.list_shifts() == [shift]
    end

    test "list_shifts_with_timeslots/1 with where filter returns only matching shifts" do
      degree1 = DegreesFixtures.degree_fixture(%{code: "DEG-#{System.unique_integer()}"})
      degree2 = DegreesFixtures.degree_fixture(%{code: "DEG-#{System.unique_integer()}"})

      course1 =
        DegreesFixtures.course_fixture(%{
          code: "C1-#{System.unique_integer()}",
          degree_id: degree1.id
        })

      course2 =
        DegreesFixtures.course_fixture(%{
          code: "C2-#{System.unique_integer()}",
          degree_id: degree2.id
        })

      shift1 = shift_fixture(%{course_id: course1.id, number: 1})
      _shift2 = shift_fixture(%{course_id: course2.id, number: 2})

      results = Shifts.list_shifts_with_timeslots(where: [course_id: course1.id])
      assert length(results) == 1
      assert hd(results).id == shift1.id
      assert Ecto.assoc_loaded?(hd(results).timeslots)
    end

    test "list_courses_with_no_parent/1 supports include_shifts: false" do
      degree = DegreesFixtures.degree_fixture(%{code: "DEG-#{System.unique_integer()}"})

      course =
        DegreesFixtures.course_fixture(%{
          code: "C-#{System.unique_integer()}",
          degree_id: degree.id
        })

      _shift = shift_fixture(%{course_id: course.id})

      courses =
        Courses.list_courses_with_no_parent(include_shifts: false)

      assert Enum.any?(courses, fn c -> c.id == course.id end)
      target_course = Enum.find(courses, fn c -> c.id == course.id end)
      refute Ecto.assoc_loaded?(target_course.shifts)
    end

    test "get_shift!/1 returns the shift with given id" do
      shift = shift_fixture()
      assert Shifts.get_shift!(shift.id) == shift
    end

    test "create_shift/1 with valid data creates a shift" do
      valid_attrs = %{
        type: :theoretical,
        number: 42,
        capacity: 42,
        professor: "some professor",
        course_id: DegreesFixtures.course_fixture().id
      }

      assert {:ok, %Shift{} = shift} = Shifts.create_shift(valid_attrs)
      assert shift.type == :theoretical
      assert shift.number == 42
      assert shift.capacity == 42
      assert shift.professor == "some professor"
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shifts.create_shift(@invalid_attrs)
    end

    test "update_shift/2 with valid data updates the shift" do
      shift = shift_fixture()

      update_attrs = %{
        type: :practical_laboratory,
        number: 43,
        capacity: 43,
        professor: "some updated professor"
      }

      assert {:ok, %Shift{} = shift} = Shifts.update_shift(shift, update_attrs)
      assert shift.type == :practical_laboratory
      assert shift.number == 43
      assert shift.capacity == 43
      assert shift.professor == "some updated professor"
    end

    test "update_shift/2 with invalid data returns error changeset" do
      shift = shift_fixture()
      assert {:error, %Ecto.Changeset{}} = Shifts.update_shift(shift, @invalid_attrs)
      assert shift == Shifts.get_shift!(shift.id)
    end

    test "delete_shift/1 deletes the shift" do
      shift = shift_fixture()
      assert {:ok, %Shift{}} = Shifts.delete_shift(shift)
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_shift!(shift.id) end
    end

    test "change_shift/1 returns a shift changeset" do
      shift = shift_fixture()
      assert %Ecto.Changeset{} = Shifts.change_shift(shift)
    end
  end

  describe "timeslots" do
    alias Atlas.University.Degrees.Courses.Shifts.Timeslot

    import Atlas.University.Degrees.Courses.ShiftsFixtures

    @invalid_attrs %{start: nil, end: nil, weekday: nil, building: nil, room: nil}

    test "list_timeslots/0 returns all timeslots" do
      timeslot = timeslot_fixture()
      assert Shifts.list_timeslots() == [timeslot]
    end

    test "get_timeslot!/1 returns the timeslot with given id" do
      timeslot = timeslot_fixture()
      assert Shifts.get_timeslot!(timeslot.id) == timeslot
    end

    test "create_timeslot/1 with valid data creates a timeslot" do
      valid_attrs = %{
        start: ~T[14:00:00],
        end: ~T[16:00:00],
        weekday: :monday,
        building: "some building",
        room: "some room",
        shift_id: shift_fixture().id
      }

      assert {:ok, %Timeslot{} = timeslot} = Shifts.create_timeslot(valid_attrs)
      assert timeslot.start == ~T[14:00:00]
      assert timeslot.end == ~T[16:00:00]
      assert timeslot.weekday == :monday
      assert timeslot.building == "some building"
      assert timeslot.room == "some room"
    end

    test "create_timeslot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shifts.create_timeslot(@invalid_attrs)
    end

    test "update_timeslot/2 with valid data updates the timeslot" do
      timeslot = timeslot_fixture()

      update_attrs = %{
        start: ~T[15:01:01],
        end: ~T[17:01:01],
        weekday: :wednesday,
        building: "some updated building",
        room: "some updated room"
      }

      assert {:ok, %Timeslot{} = timeslot} = Shifts.update_timeslot(timeslot, update_attrs)
      assert timeslot.start == ~T[15:01:01]
      assert timeslot.end == ~T[17:01:01]
      assert timeslot.weekday == :wednesday
      assert timeslot.building == "some updated building"
      assert timeslot.room == "some updated room"
    end

    test "update_timeslot/2 with invalid data returns error changeset" do
      timeslot = timeslot_fixture()
      assert {:error, %Ecto.Changeset{}} = Shifts.update_timeslot(timeslot, @invalid_attrs)
      assert timeslot == Shifts.get_timeslot!(timeslot.id)
    end

    test "delete_timeslot/1 deletes the timeslot" do
      timeslot = timeslot_fixture()
      assert {:ok, %Timeslot{}} = Shifts.delete_timeslot(timeslot)
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_timeslot!(timeslot.id) end
    end

    test "change_timeslot/1 returns a timeslot changeset" do
      timeslot = timeslot_fixture()
      assert %Ecto.Changeset{} = Shifts.change_timeslot(timeslot)
    end

    test "update_shift_with_timeslots/3 updates, inserts, and deletes omitted timeslots" do
      shift = shift_fixture()

      ts1 =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :monday,
          start: ~T[09:00:00],
          end: ~T[11:00:00]
        })

      ts2 =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :tuesday,
          start: ~T[14:00:00],
          end: ~T[16:00:00]
        })

      loaded_shift = Shifts.get_shift_with_timeslots(shift.id)
      assert length(loaded_shift.timeslots) == 2

      # We omit ts2 (should be deleted), update ts1, and insert a new slot
      timeslot_attrs = [
        %{"id" => ts1.id, "weekday" => "wednesday", "start" => "10:00:00", "end" => "12:00:00"},
        %{"weekday" => "friday", "start" => "08:00:00", "end" => "10:00:00"}
      ]

      assert {:ok, %{shift: updated_shift}} =
               Shifts.update_shift_with_timeslots(
                 loaded_shift,
                 %{"professor" => "Updated Prof"},
                 timeslot_attrs
               )

      assert updated_shift.professor == "Updated Prof"
      assert length(updated_shift.timeslots) == 2

      timeslot_ids = Enum.map(updated_shift.timeslots, & &1.id)
      assert ts1.id in timeslot_ids
      refute ts2.id in timeslot_ids

      # Verify ts2 was deleted from database
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_timeslot!(ts2.id) end
    end

    test "preloading timeslots orders chronologically by weekday (Monday-Sunday) and start time" do
      shift = shift_fixture()

      # Insert out of chronological and alphabetical order: Friday, Tuesday, Monday (afternoon), Monday (morning)
      _ts_friday =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :friday,
          start: ~T[09:00:00],
          end: ~T[11:00:00]
        })

      _ts_tuesday =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :tuesday,
          start: ~T[10:00:00],
          end: ~T[12:00:00]
        })

      _ts_monday_afternoon =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :monday,
          start: ~T[14:00:00],
          end: ~T[16:00:00]
        })

      _ts_monday_morning =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :monday,
          start: ~T[08:00:00],
          end: ~T[10:00:00]
        })

      loaded_shift = Shifts.get_shift_with_timeslots(shift.id)

      assert Enum.map(loaded_shift.timeslots, fn ts -> {ts.weekday, ts.start} end) == [
               {:monday, ~T[08:00:00]},
               {:monday, ~T[14:00:00]},
               {:tuesday, ~T[10:00:00]},
               {:friday, ~T[09:00:00]}
             ]
    end
  end
end
