defmodule Atlas.Feedbacks do
  @moduledoc """
  The Feedbacks context.
  """

  use Atlas.Context
  alias Atlas.Repo

  alias Atlas.Feedbacks.Feedback

  @doc """
  Returns the list of feedbacks, newest first unless `:order_by` is given.

  ## Examples

      iex> list_feedbacks()
      [%Feedback{}, ...]

  """
  def list_feedbacks(opts \\ []) do
    opts = Keyword.put_new(opts, :order_by, desc: :inserted_at)

    Feedback
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Gets a single feedback.

  Returns `nil` if the feedback does not exist or `id` is not a valid UUID.

  ## Examples

      iex> get_feedback("0b5a6c1e-...")
      %Feedback{}

      iex> get_feedback("not-a-uuid")
      nil

  """
  def get_feedback(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Repo.get(Feedback, uuid)
      :error -> nil
    end
  end

  @doc """
  Creates a feedback.

  ## Examples

      iex> create_feedback(%{field: value})
      {:ok, %Feedback{}}

      iex> create_feedback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_feedback(attrs \\ %{}) do
    %Feedback{}
    |> Feedback.changeset(attrs)
    |> Repo.insert()
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
