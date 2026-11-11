defmodule Atlas.Feedbacks do
  @moduledoc """
  The Feedbacks context.
  """

  use Atlas.Context

  alias Atlas.Feedbacks.Feedback

  @doc """
  Returns a page of feedbacks with their user, newest first.

  Accepts Flop params such as `page` and `page_size`.

  ## Examples

      iex> list_feedbacks(%{"page" => 1})
      {:ok, {[%Feedback{}, ...], %Flop.Meta{}}}

      iex> list_feedbacks(%{"page" => -1})
      {:error, %Flop.Meta{}}

  """
  def list_feedbacks(params \\ %{}) do
    Feedback
    |> preload(:user)
    |> Flop.validate_and_run(params, for: Feedback)
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
