defmodule AtlasWeb.FeedbacksJSON do
  alias Atlas.Feedbacks.Feedback

  @doc """
  Renders a list of feedbacks.
  """
  def index(%{feedbacks: feedbacks}) do
    %{data: for(feedback <- feedbacks, do: data(feedback))}
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
      user_id: feedback.user_id,
      inserted_at: feedback.inserted_at
    }
  end
end
