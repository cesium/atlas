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
      valid_attrs = %{name: "some name"}

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
end
