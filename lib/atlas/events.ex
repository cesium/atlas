defmodule Atlas.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Atlas.Repo

  alias Atlas.Events.EventCategory
  alias Atlas.Events.Event

  @doc """
  Returns the list of event_categories.

  ## Examples

      iex> list_event_categories()
      [%EventCategory{}, ...]

  """
  def list_event_categories do
    EventCategory
    |> preload(:course)
    |> Repo.all()
  end

  @doc """
  Gets a single event_category.

  Raises `Ecto.NoResultsError` if the Event category does not exist.

  ## Examples

      iex> get_event_category!(123)
      %EventCategory{}

      iex> get_event_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_category!(id) do
    EventCategory
    |> preload(:course)
    |> Repo.get!(id)
  end

  @doc """
  Creates a event_category.

  ## Examples

      iex> create_event_category(%{field: value})
      {:ok, %EventCategory{}}

      iex> create_event_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_category(attrs \\ %{}) do
    %EventCategory{}
    |> EventCategory.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, event_category} -> {:ok, Repo.preload(event_category, :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a event_category.

  ## Examples

      iex> update_event_category(event_category, %{field: new_value})
      {:ok, %EventCategory{}}

      iex> update_event_category(event_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_category(%EventCategory{} = event_category, attrs) do
    event_category
    |> EventCategory.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, event_category} -> {:ok, Repo.preload(event_category, :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a event_category.

  ## Examples

      iex> delete_event_category(event_category)
      {:ok, %EventCategory{}}

      iex> delete_event_category(event_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_category(%EventCategory{} = event_category) do
    Repo.delete(event_category)
    |> case do
      {:ok, event_category} -> {:ok, Repo.preload(event_category, :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_category changes.

  ## Examples

      iex> change_event_category(event_category)
      %Ecto.Changeset{data: %EventCategory{}}

  """
  def change_event_category(%EventCategory{} = event_category, attrs \\ %{}) do
    EventCategory.changeset(event_category, attrs)
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Event
    |> preload(category: :course)
    |> Repo.all()
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do
    Event
    |> preload(category: :course)
    |> Repo.get!(id)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, category: :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, category: :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, category: :course)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end
end
