defmodule Atlas.UniversityTest do
  use Atlas.DataCase

  alias Atlas.University

  describe "students" do
    alias Atlas.University.Student

    import Atlas.UniversityFixtures

    @invalid_attrs %{number: nil, special_status: nil, degree_year: nil}

    test "list_students/0 returns all students" do
      student = student_fixture()
      assert University.list_students() == [student]
    end

    test "get_student!/1 returns the student with given id" do
      student = student_fixture()
      assert University.get_student!(student.id) == student
    end

    test "create_student/1 with valid data creates a student" do
      valid_attrs = %{
        number: "some number",
        special_status: "some special_status",
        degree_year: 42
      }

      assert {:ok, %Student{} = student} = University.create_student(valid_attrs)
      assert student.number == "some number"
      assert student.special_status == "some special_status"
      assert student.degree_year == 42
    end

    test "create_student/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = University.create_student(@invalid_attrs)
    end

    test "update_student/2 with valid data updates the student" do
      student = student_fixture()

      update_attrs = %{
        number: "some updated number",
        special_status: "some updated special_status",
        degree_year: 43
      }

      assert {:ok, %Student{} = student} = University.update_student(student, update_attrs)
      assert student.number == "some updated number"
      assert student.special_status == "some updated special_status"
      assert student.degree_year == 43
    end

    test "update_student/2 with invalid data returns error changeset" do
      student = student_fixture()
      assert {:error, %Ecto.Changeset{}} = University.update_student(student, @invalid_attrs)
      assert student == University.get_student!(student.id)
    end

    test "delete_student/1 deletes the student" do
      student = student_fixture()
      assert {:ok, %Student{}} = University.delete_student(student)
      assert_raise Ecto.NoResultsError, fn -> University.get_student!(student.id) end
    end

    test "change_student/1 returns a student changeset" do
      student = student_fixture()
      assert %Ecto.Changeset{} = University.change_student(student)
    end
  end
end
