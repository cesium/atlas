defmodule Atlas.UniversityTest do
  use Atlas.DataCase

  alias Atlas.University

  describe "students" do
    alias Atlas.University.Student

    import Atlas.UniversityFixtures
    import Atlas.DegreesFixtures

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
        degree_year: 1,
        degree_id: degree_fixture().id
      }

      assert {:ok, %Student{} = student} = University.create_student(valid_attrs)
      assert student.number == "some number"
      assert student.special_status == "some special_status"
      assert student.degree_year == 1
    end

    test "create_student/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = University.create_student(@invalid_attrs)
    end

    test "update_student/2 with valid data updates the student" do
      student = student_fixture()

      update_attrs = %{
        number: "some updated number",
        special_status: "some updated special_status",
        degree_year: 1
      }

      assert {:ok, %Student{} = student} = University.update_student(student, update_attrs)
      assert student.number == "some updated number"
      assert student.special_status == "some updated special_status"
      assert student.degree_year == 1
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

  describe "course_enrollments" do
    alias Atlas.University.CourseEnrollment

    import Atlas.UniversityFixtures
    import Atlas.DegreesFixtures

    @invalid_attrs %{course_id: nil, student_id: nil}

    test "list_course_enrollments/0 returns all course_enrollments" do
      course_enrollment = course_enrollment_fixture()
      assert University.list_course_enrollments() == [course_enrollment]
    end

    test "get_course_enrollment!/1 returns the course_enrollment with given id" do
      course_enrollment = course_enrollment_fixture()
      assert University.get_course_enrollment!(course_enrollment.id) == course_enrollment
    end

    test "create_course_enrollment/1 with valid data creates a course_enrollment" do
      valid_attrs = %{course_id: course_fixture().id, student_id: student_fixture().id}

      assert {:ok, %CourseEnrollment{} = _course_enrollment} =
               University.create_course_enrollment(valid_attrs)
    end

    test "create_course_enrollment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = University.create_course_enrollment(@invalid_attrs)
    end

    test "update_course_enrollment/2 with valid data updates the course_enrollment" do
      course_enrollment = course_enrollment_fixture()
      update_attrs = %{}

      assert {:ok, %CourseEnrollment{} = _course_enrollment} =
               University.update_course_enrollment(course_enrollment, update_attrs)
    end

    test "update_course_enrollment/2 with invalid data returns error changeset" do
      course_enrollment = course_enrollment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               University.update_course_enrollment(course_enrollment, @invalid_attrs)

      assert course_enrollment == University.get_course_enrollment!(course_enrollment.id)
    end

    test "delete_course_enrollment/1 deletes the course_enrollment" do
      course_enrollment = course_enrollment_fixture()
      assert {:ok, %CourseEnrollment{}} = University.delete_course_enrollment(course_enrollment)

      assert_raise Ecto.NoResultsError, fn ->
        University.get_course_enrollment!(course_enrollment.id)
      end
    end

    test "change_course_enrollment/1 returns a course_enrollment changeset" do
      course_enrollment = course_enrollment_fixture()
      assert %Ecto.Changeset{} = University.change_course_enrollment(course_enrollment)
    end
  end

  describe "shift_enrollments" do
    alias Atlas.University.ShiftEnrollment

    import Atlas.UniversityFixtures
    import Atlas.DegreesFixtures
    import Atlas.University.Degrees.Courses.ShiftsFixtures

    @invalid_attrs %{status: nil, student_id: nil, shift_id: nil}

    test "list_shift_enrollments/0 returns all shift_enrollments" do
      shift_enrollment = shift_enrollment_fixture()
      assert University.list_shift_enrollments() == [shift_enrollment]
    end

    test "get_shift_enrollment!/1 returns the shift_enrollment with given id" do
      shift_enrollment = shift_enrollment_fixture()
      assert University.get_shift_enrollment!(shift_enrollment.id) == shift_enrollment
    end

    test "create_shift_enrollment/1 with valid data creates a shift_enrollment" do
      valid_attrs = %{
        status: :active,
        student_id: student_fixture().id,
        shift_id: shift_fixture().id
      }

      assert {:ok, %ShiftEnrollment{} = shift_enrollment} =
               University.create_shift_enrollment(valid_attrs)

      assert shift_enrollment.status == :active
    end

    test "create_shift_enrollment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = University.create_shift_enrollment(@invalid_attrs)
    end

    test "update_shift_enrollment/2 with valid data updates the shift_enrollment" do
      shift_enrollment = shift_enrollment_fixture()
      update_attrs = %{status: :inactive}

      assert {:ok, %ShiftEnrollment{} = shift_enrollment} =
               University.update_shift_enrollment(shift_enrollment, update_attrs)

      assert shift_enrollment.status == :inactive
    end

    test "update_shift_enrollment/2 with invalid data returns error changeset" do
      shift_enrollment = shift_enrollment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               University.update_shift_enrollment(shift_enrollment, @invalid_attrs)

      assert shift_enrollment == University.get_shift_enrollment!(shift_enrollment.id)
    end

    test "delete_shift_enrollment/1 deletes the shift_enrollment" do
      shift_enrollment = shift_enrollment_fixture()
      assert {:ok, %ShiftEnrollment{}} = University.delete_shift_enrollment(shift_enrollment)

      assert_raise Ecto.NoResultsError, fn ->
        University.get_shift_enrollment!(shift_enrollment.id)
      end
    end

    test "change_shift_enrollment/1 returns a shift_enrollment changeset" do
      shift_enrollment = shift_enrollment_fixture()
      assert %Ecto.Changeset{} = University.change_shift_enrollment(shift_enrollment)
    end
  end
end
