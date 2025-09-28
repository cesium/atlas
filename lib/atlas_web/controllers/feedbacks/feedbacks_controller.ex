defmodule AtlasWeb.FeedbacksController do
  use AtlasWeb, :controller

  alias Atlas.Feedbacks
  alias Atlas.Feedbacks.Feedback

  action_fallback AtlasWeb.FallbackController

  def index(conn, _attrs) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    feedbacks =
      if user_has_elevated_privileges?(user) do
        Feedbacks.list_feedbacks()
      else
        Feedbacks.list_feedbacks(where: [user_id: user.id])
      end

    render(conn, :index, feedbacks: feedbacks)
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
    {user, _session} = Guardian.Plug.current_resource(conn)

    if user_has_elevated_privileges?(user) do
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
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Unauthorized"})
    end
  end

  defp user_has_elevated_privileges?(user) do
    (user && user.type == :admin) || user.type == :professor
  end
end
