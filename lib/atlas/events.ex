defmodule Atlas.Events do
  @moduledoc """
  The Events context.
  """

  use Atlas.Context

  alias Atlas.Events.EventGroup

  @doc """
  Returns the list of event_groups.

  ## Examples

      iex> list_event_groups()
      [%EventGroup{}, ...]

  """
  def list_event_groups do
    Repo.all(EventGroup)
  end

  @doc """
  Gets a single event_group.

  Raises `Ecto.NoResultsError` if the Event group does not exist.

  ## Examples

      iex> get_event_group!(123)
      %EventGroup{}

      iex> get_event_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_group!(id), do: Repo.get!(EventGroup, id)

  @doc """
  Creates a event_group.

  ## Examples

      iex> create_event_group(%{field: value})
      {:ok, %EventGroup{}}

      iex> create_event_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_group(attrs \\ %{}) do
    %EventGroup{}
    |> EventGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event_group.

  ## Examples

      iex> update_event_group(event_group, %{field: new_value})
      {:ok, %EventGroup{}}

      iex> update_event_group(event_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_group(%EventGroup{} = event_group, attrs) do
    event_group
    |> EventGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_group.

  ## Examples

      iex> delete_event_group(event_group)
      {:ok, %EventGroup{}}

      iex> delete_event_group(event_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_group(%EventGroup{} = event_group) do
    Repo.delete(event_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_group changes.

  ## Examples

      iex> change_event_group(event_group)
      %Ecto.Changeset{data: %EventGroup{}}

  """
  def change_event_group(%EventGroup{} = event_group, attrs \\ %{}) do
    EventGroup.changeset(event_group, attrs)
  end
end
