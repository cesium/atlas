defmodule Atlas.EventsTest do
  use Atlas.DataCase

  alias Atlas.Events

  describe "event_groups" do
    alias Atlas.Events.EventGroup

    import Atlas.EventsFixtures

    @invalid_attrs %{name: nil, foreground_color: nil, background_color: nil}

    test "list_event_groups/0 returns all event_groups" do
      event_group = event_group_fixture()
      assert Events.list_event_groups() == [event_group]
    end

    test "get_event_group!/1 returns the event_group with given id" do
      event_group = event_group_fixture()
      assert Events.get_event_group!(event_group.id) == event_group
    end

    test "create_event_group/1 with valid data creates a event_group" do
      valid_attrs = %{name: "some name", foreground_color: "some foreground_color", background_color: "some background_color"}

      assert {:ok, %EventGroup{} = event_group} = Events.create_event_group(valid_attrs)
      assert event_group.name == "some name"
      assert event_group.foreground_color == "some foreground_color"
      assert event_group.background_color == "some background_color"
    end

    test "create_event_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_group(@invalid_attrs)
    end

    test "update_event_group/2 with valid data updates the event_group" do
      event_group = event_group_fixture()
      update_attrs = %{name: "some updated name", foreground_color: "some updated foreground_color", background_color: "some updated background_color"}

      assert {:ok, %EventGroup{} = event_group} = Events.update_event_group(event_group, update_attrs)
      assert event_group.name == "some updated name"
      assert event_group.foreground_color == "some updated foreground_color"
      assert event_group.background_color == "some updated background_color"
    end

    test "update_event_group/2 with invalid data returns error changeset" do
      event_group = event_group_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event_group(event_group, @invalid_attrs)
      assert event_group == Events.get_event_group!(event_group.id)
    end

    test "delete_event_group/1 deletes the event_group" do
      event_group = event_group_fixture()
      assert {:ok, %EventGroup{}} = Events.delete_event_group(event_group)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_group!(event_group.id) end
    end

    test "change_event_group/1 returns a event_group changeset" do
      event_group = event_group_fixture()
      assert %Ecto.Changeset{} = Events.change_event_group(event_group)
    end
  end
end
