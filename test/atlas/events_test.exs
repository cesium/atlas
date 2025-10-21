defmodule Atlas.EventsTest do
  use Atlas.DataCase

  alias Atlas.Events

  describe "event_categories" do
    alias Atlas.Events.EventCategory

    import Atlas.EventsFixtures

  @invalid_attrs %{name: nil, color: nil, type: nil}

    test "list_event_categories/0 returns all event_categories" do
      event_category = event_category_fixture()
      assert Events.list_event_categories() == [event_category]
    end

    test "get_event_category!/1 returns the event_category with given id" do
      event_category = event_category_fixture()
      assert Events.get_event_category!(event_category.id) == event_category
    end

    test "create_event_category/1 with valid data creates a event_category" do
  valid_attrs = %{name: "some name", color: "some color", type: "optional"}

      assert {:ok, %EventCategory{} = event_category} = Events.create_event_category(valid_attrs)
      assert event_category.name == "some name"
      assert event_category.color == "some color"
    end

    test "create_event_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_category(@invalid_attrs)
    end

    test "update_event_category/2 with valid data updates the event_category" do
      event_category = event_category_fixture()
      update_attrs = %{name: "some updated name", color: "some updated color"}

      assert {:ok, %EventCategory{} = event_category} =
               Events.update_event_category(event_category, update_attrs)

      assert event_category.name == "some updated name"
      assert event_category.color == "some updated color"
    end

    test "update_event_category/2 with invalid data returns error changeset" do
      event_category = event_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Events.update_event_category(event_category, @invalid_attrs)

      assert event_category == Events.get_event_category!(event_category.id)
    end

    test "delete_event_category/1 deletes the event_category" do
      event_category = event_category_fixture()
      assert {:ok, %EventCategory{}} = Events.delete_event_category(event_category)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_category!(event_category.id) end
    end

    test "change_event_category/1 returns a event_category changeset" do
      event_category = event_category_fixture()
      assert %Ecto.Changeset{} = Events.change_event_category(event_category)
    end
  end

  describe "events" do
    alias Atlas.Events.Event

    import Atlas.EventsFixtures

    @invalid_attrs %{start: nil, link: nil, title: nil, end: nil, place: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      category = event_category_fixture()

      valid_attrs = %{
        start: ~U[2025-01-01 14:00:00Z],
        link: "some link",
        title: "some title",
        end: ~U[2025-01-01 14:00:00Z],
        place: "some place",
        category_id: category.id
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
  assert event.start == ~U[2025-01-01 14:00:00Z]
      assert event.link == "some link"
      assert event.title == "some title"
  assert event.end == ~U[2025-01-01 14:00:00Z]
      assert event.place == "some place"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
  start: ~U[2025-01-01 15:01:01Z],
        link: "some updated link",
        title: "some updated title",
  end: ~U[2025-01-01 15:01:01Z],
        place: "some updated place"
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
  assert event.start == ~U[2025-01-01 15:01:01Z]
      assert event.link == "some updated link"
      assert event.title == "some updated title"
  assert event.end == ~U[2025-01-01 15:01:01Z]
      assert event.place == "some updated place"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
