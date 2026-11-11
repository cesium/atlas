defmodule AtlasWeb.FeedbacksController do
  use AtlasWeb, :controller

  alias Atlas.Feedbacks
  alias Atlas.Feedbacks.Feedback

  action_fallback AtlasWeb.FallbackController

  def index(conn, params) do
    case Feedbacks.list_feedbacks(params) do
      {:ok, {feedbacks, meta}} ->
        render(conn, :index, feedbacks: feedbacks, meta: meta)

      {:error, _meta} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: %{detail: "Invalid pagination parameters"}})
    end
  end

  def show(conn, %{"id" => id}) do
    case Feedbacks.get_feedback(id) do
      nil -> not_found(conn)
      feedback -> render(conn, :show, feedback: feedback)
    end
  end

  def create(conn, attrs) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    attrs = Map.put(attrs, "user_id", user.id)

    with {:ok, %Feedback{} = feedback} <- Feedbacks.create_feedback(attrs) do
      conn
      |> put_status(:created)
      |> render(:show, feedback: feedback)
    end
  end

  def delete(conn, %{"id" => id}) do
    case Feedbacks.get_feedback(id) do
      nil ->
        not_found(conn)

      feedback ->
        with {:ok, %Feedback{}} <- Feedbacks.delete_feedback(feedback) do
          send_resp(conn, :no_content, "")
        end
    end
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{error: "Feedback not found"})
  end
end
