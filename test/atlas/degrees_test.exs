defmodule Atlas.DegreesTest do
  use Atlas.DataCase

  alias Atlas.Degrees

  describe "degrees" do
    alias Atlas.Degrees.Degree

    import Atlas.DegreesFixtures

    @invalid_attrs %{name: nil}

    test "list_degrees/0 returns all degrees" do
      degree = degree_fixture()
      assert Degrees.list_degrees() == [degree]
    end

    test "get_degree!/1 returns the degree with given id" do
      degree = degree_fixture()
      assert Degrees.get_degree!(degree.id) == degree
    end

    test "create_degree/1 with valid data creates a degree" do
      valid_attrs = %{name: "some name", code: "code"}

      assert {:ok, %Degree{} = degree} = Degrees.create_degree(valid_attrs)
      assert degree.name == "some name"
    end

    test "create_degree/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Degrees.create_degree(@invalid_attrs)
    end

    test "update_degree/2 with valid data updates the degree" do
      degree = degree_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Degree{} = degree} = Degrees.update_degree(degree, update_attrs)
      assert degree.name == "some updated name"
    end

    test "update_degree/2 with invalid data returns error changeset" do
      degree = degree_fixture()
      assert {:error, %Ecto.Changeset{}} = Degrees.update_degree(degree, @invalid_attrs)
      assert degree == Degrees.get_degree!(degree.id)
    end

    test "delete_degree/1 deletes the degree" do
      degree = degree_fixture()
      assert {:ok, %Degree{}} = Degrees.delete_degree(degree)
      assert_raise Ecto.NoResultsError, fn -> Degrees.get_degree!(degree.id) end
    end

    test "change_degree/1 returns a degree changeset" do
      degree = degree_fixture()
      assert %Ecto.Changeset{} = Degrees.change_degree(degree)
    end
  end

  describe "courses" do
    alias Atlas.Degrees.Course

    import Atlas.DegreesFixtures

    @invalid_attrs %{code: nil, name: nil, year: nil, semester: nil}

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      assert Degrees.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Degrees.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      valid_attrs = %{
        code: "code",
        name: "some name",
        year: 1,
        semester: 1,
        degree_id: degree_fixture().id
      }

      assert {:ok, %Course{} = course} = Degrees.create_course(valid_attrs)
      assert course.code == "code"
      assert course.name == "some name"
      assert course.year == 1
      assert course.semester == 1
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Degrees.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      update_attrs = %{code: "code", name: "some updated name", year: 43, semester: 43}

      assert {:ok, %Course{} = course} = Degrees.update_course(course, update_attrs)
      assert course.code == "code"
      assert course.name == "some updated name"
      assert course.year == 43
      assert course.semester == 43
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Degrees.update_course(course, @invalid_attrs)
      assert course == Degrees.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Degrees.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Degrees.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Degrees.change_course(course)
    end
  end
end
