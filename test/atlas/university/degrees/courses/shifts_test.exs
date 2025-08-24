defmodule Atlas.University.Degrees.Courses.ShiftsTest do
  use Atlas.DataCase

  alias Atlas.DegreesFixtures
  alias Atlas.University.Degrees.Courses.Shifts

  describe "shifts" do
    alias Atlas.University.Degrees.Courses.Shifts.Shift

    import Atlas.University.Degrees.Courses.ShiftsFixtures

    @invalid_attrs %{type: nil, number: nil, capacity: nil, professor: nil}

    test "list_shifts/0 returns all shifts" do
      shift = shift_fixture()
      assert Shifts.list_shifts() == [shift]
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
        end: ~T[14:00:00],
        weekday: :monday,
        building: "some building",
        room: "some room",
        shift_id: shift_fixture().id
      }

      assert {:ok, %Timeslot{} = timeslot} = Shifts.create_timeslot(valid_attrs)
      assert timeslot.start == ~T[14:00:00]
      assert timeslot.end == ~T[14:00:00]
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
        end: ~T[15:01:01],
        weekday: :wednesday,
        building: "some updated building",
        room: "some updated room"
      }

      assert {:ok, %Timeslot{} = timeslot} = Shifts.update_timeslot(timeslot, update_attrs)
      assert timeslot.start == ~T[15:01:01]
      assert timeslot.end == ~T[15:01:01]
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
  end
end
