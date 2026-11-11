defmodule Atlas.Feedbacks do
  @moduledoc """
  The Feedbacks context.
  """

  use Atlas.Context

  alias Atlas.Feedbacks.Feedback

  @doc """
  Returns the list of feedbacks with their user, newest first unless `:order_by` is given.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:order_by, desc: :inserted_at)
      |> Keyword.put_new(:preloads, :user)

    Feedback
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single feedback with its user.

  Returns `nil` if the feedback does not exist or `id` is not a valid UUID.

  ## Examples

      iex> get_feedback("0b5a6c1e-...")
      %Feedback{}

      iex> get_feedback("not-a-uuid")
      nil

  """
  def get_feedback(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Feedback |> Repo.get(uuid) |> Repo.preload(:user)
      :error -> nil
    end
  end

  @doc """
  Creates a feedback and returns it with its user.

  ## Examples

      iex> create_feedback(%{field: value})
      {:ok, %Feedback{}}

      iex> create_feedback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feedback(attrs \\ %{}) do
    with {:ok, feedback} <- %Feedback{} |> Feedback.changeset(attrs) |> Repo.insert() do
      {:ok, Repo.preload(feedback, :user)}
    end
  end

  @doc """
  Updates a feedback.

  ## Examples

      iex> update_feedback(feedback, %{field: new_value})
      {:ok, %Feedback{}}

      iex> update_feedback(feedback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a feedback.

  ## Examples

      iex> delete_feedback(feedback)
      {:ok, %Feedback{}}

      iex> delete_feedback(feedback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking feedback changes.

  ## Examples

      iex> change_feedback(feedback)
      %Ecto.Changeset{data: %Feedback{}}

  """
  def change_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    Feedback.changeset(feedback, attrs)
  end
end
