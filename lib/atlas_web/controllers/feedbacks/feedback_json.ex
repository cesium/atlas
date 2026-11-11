defmodule AtlasWeb.FeedbacksJSON do
  alias Atlas.Feedbacks.Feedback
  alias AtlasWeb.MetaJSON

  @doc """
  Renders a page of feedbacks with its pagination meta.
  """
  def index(%{feedbacks: feedbacks, meta: meta}) do
    %{
      data: for(feedback <- feedbacks, do: data(feedback)),
      meta: MetaJSON.data(meta)
    }
  end

  @doc """
  Renders a single feedback.
  """
  def show(%{feedback: feedback}) do
    %{data: data(feedback)}
  end

  defp data(%Feedback{} = feedback) do
    %{
      id: feedback.id,
      subject: feedback.subject,
      message: feedback.message,
      user: %{
        id: feedback.user.id,
        name: feedback.user.name
      },
      inserted_at: feedback.inserted_at
    }
  end
end
