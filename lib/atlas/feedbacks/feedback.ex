defmodule Atlas.Feedbacks.Feedback do
  @moduledoc """
  The Feedback schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(subject message user_id)a
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "feedbacks" do
    field :message, :string
    field :subject, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
