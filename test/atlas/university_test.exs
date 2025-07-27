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

  describe "enrollments" do
    alias Atlas.University.Enrollment

    import Atlas.UniversityFixtures

    @invalid_attrs %{}

    test "list_enrollments/0 returns all enrollments" do
      enrollment = enrollment_fixture()
      assert University.list_enrollments() == [enrollment]
    end

    test "get_enrollment!/1 returns the enrollment with given id" do
      enrollment = enrollment_fixture()
      assert University.get_enrollment!(enrollment.id) == enrollment
    end

    test "create_enrollment/1 with valid data creates a enrollment" do
      valid_attrs = %{}

      assert {:ok, %Enrollment{} = enrollment} = University.create_enrollment(valid_attrs)
    end

    test "create_enrollment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = University.create_enrollment(@invalid_attrs)
    end

    test "update_enrollment/2 with valid data updates the enrollment" do
      enrollment = enrollment_fixture()
      update_attrs = %{}

      assert {:ok, %Enrollment{} = enrollment} =
               University.update_enrollment(enrollment, update_attrs)
    end

    test "update_enrollment/2 with invalid data returns error changeset" do
      enrollment = enrollment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               University.update_enrollment(enrollment, @invalid_attrs)

      assert enrollment == University.get_enrollment!(enrollment.id)
    end

    test "delete_enrollment/1 deletes the enrollment" do
      enrollment = enrollment_fixture()
      assert {:ok, %Enrollment{}} = University.delete_enrollment(enrollment)
      assert_raise Ecto.NoResultsError, fn -> University.get_enrollment!(enrollment.id) end
    end

    test "change_enrollment/1 returns a enrollment changeset" do
      enrollment = enrollment_fixture()
      assert %Ecto.Changeset{} = University.change_enrollment(enrollment)
    end
  end
end
