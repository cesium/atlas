defmodule AtlasWeb.FeedbacksController do
  use AtlasWeb, :controller

  alias Atlas.Feedbacks
  alias Atlas.Feedbacks.Feedback

  action_fallback AtlasWeb.FallbackController

  def index(conn, _attrs) do
    feedbacks = Feedbacks.list_feedbacks()

    render(conn, :index, feedbacks: feedbacks)
  end

  def show(conn, %{"id" => id}) do
    feedback = Feedbacks.get_feedback!(id)

    render(conn, :show, feedback: feedback)
  end

  def create(conn, attrs) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    attrs = Map.put(attrs, "user_id", user.id)

    case Feedbacks.create_feedback(attrs) do
      {:ok, feedback} ->
        conn
        |> put_status(:created)
        |> render(:show, feedback: feedback)

      {:error, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: "Invalid fields"})
    end
  end

  def delete(conn, %{"id" => id}) do
    {_user, _session} = Guardian.Plug.current_resource(conn)

    case Feedbacks.get_feedback!(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Feedback not found"})

      feedback ->
        with {:ok, %Feedback{}} <- Feedbacks.delete_feedback(feedback) do
          send_resp(conn, :no_content, "")
        end
    end

  end
end
