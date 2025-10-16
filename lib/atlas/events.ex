defmodule Atlas.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Atlas.Repo

  alias Atlas.Events.{Event, EventCategory, UserEventCategory}

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
  Returns the list of event categories selected by a user.

  ## Examples

      iex> list_event_categories_by_user(user_id)
      [%EventCategory{}, ...]

  """
  def list_event_categories_by_user(user_id) do
    EventCategory
    |> join(:left, [ec], uec in assoc(ec, :users_event_categories))
    |> where([ec, uec], uec.user_id == ^user_id or ec.type == :mandatory)
    |> preload(:course)
    |> Repo.all()
  end

  @doc """
  Updates the event categories selected by a user.

  ## Examples
      iex> update_event_categories_for_user(user_id, category_ids)
      {:ok, [%UserEventCategory{}, ...]}

      iex> update_event_categories_for_user(user_id, bad_category_ids)
      {:error, %Ecto.Changeset{}}
  """
  def update_event_categories_for_user(user_id, category_ids) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_all,
      UserEventCategory
      |> where([uec], uec.user_id == ^user_id)
    )
    |> Ecto.Multi.run(:insert_all, fn repo, _changes ->
      insert_user_event_categories(repo, user_id, category_ids)
    end)
    |> Repo.transact()
  end

  defp insert_user_event_categories(repo, user_id, category_ids) do
    category_ids
    |> Enum.reduce_while({:ok, []}, fn category_id, {:ok, acc} ->
      %UserEventCategory{}
      |> UserEventCategory.changeset(%{user_id: user_id, event_category_id: category_id})
      |> repo.insert()
      |> case do
        {:ok, user_event_category} -> {:cont, {:ok, [user_event_category | acc]}}
        {:error, changeset} -> {:halt, {:error, changeset}}
      end
    end)
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

  def list_events_by_user(user_id) do
    Event
    |> join(:inner, [e], ec in assoc(e, :category))
    |> join(:left, [e, ec], uec in assoc(ec, :users_event_categories))
    |> where([e, ec, uec], uec.user_id == ^user_id or ec.type == :mandatory)
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
