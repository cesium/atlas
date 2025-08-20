defmodule Atlas.University.Degrees.Courses.ShiftsTest do
  use Atlas.DataCase

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
      valid_attrs = %{type: "some type", number: 42, capacity: 42, professor: "some professor"}

      assert {:ok, %Shift{} = shift} = Shifts.create_shift(valid_attrs)
      assert shift.type == "some type"
      assert shift.number == 42
      assert shift.capacity == 42
      assert shift.professor == "some professor"
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shifts.create_shift(@invalid_attrs)
    end

    test "update_shift/2 with valid data updates the shift" do
      shift = shift_fixture()
      update_attrs = %{type: "some updated type", number: 43, capacity: 43, professor: "some updated professor"}

      assert {:ok, %Shift{} = shift} = Shifts.update_shift(shift, update_attrs)
      assert shift.type == "some updated type"
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
end
