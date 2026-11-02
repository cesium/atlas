defmodule AtlasWeb.FeedbacksControllerTest do
  use AtlasWeb.ConnCase

  alias Atlas.Feedbacks

  defp create_feedback(user_id) do
    {:ok, feedback} =
      Feedbacks.create_feedback(%{
        "subject" => "Bug",
        "message" => "Broken",
        "user_id" => user_id
      })

    feedback
  end

  defp professor_conn, do: authenticated_conn(%{type: :professor})

  describe "create" do
    test "creates feedback for the current user with a long message" do
      conn = authenticated_conn()
      message = String.duplicate("x", 1000)

      conn = post(conn, "/v1/feedbacks", %{"subject" => "Bug", "message" => message})

      assert %{"data" => %{"id" => _, "subject" => "Bug", "message" => ^message}} =
               json_response(conn, 201)
    end

    test "returns per-field errors when fields are missing" do
      conn = post(authenticated_conn(), "/v1/feedbacks", %{})

      assert %{"errors" => %{"subject" => [_], "message" => [_]}} = json_response(conn, 422)
    end

    test "returns a field error when subject is too long" do
      conn =
        post(authenticated_conn(), "/v1/feedbacks", %{
          "subject" => String.duplicate("s", 300),
          "message" => "m"
        })

      assert %{"errors" => %{"subject" => [_]}} = json_response(conn, 422)
    end
  end

  describe "show" do
    test "returns the feedback" do
      conn = professor_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      feedback = create_feedback(user.id)

      conn = get(conn, "/v1/feedbacks/#{feedback.id}")

      assert %{"data" => %{"id" => id}} = json_response(conn, 200)
      assert id == feedback.id
    end

    test "returns 404 for an unknown id" do
      conn = get(professor_conn(), "/v1/feedbacks/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end

    test "returns 404 for a malformed id" do
      conn = get(professor_conn(), "/v1/feedbacks/abc")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end
  end

  describe "delete" do
    test "deletes the feedback" do
      conn = professor_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      feedback = create_feedback(user.id)

      conn = delete(conn, "/v1/feedbacks/#{feedback.id}")

      assert response(conn, 204)
      assert Feedbacks.get_feedback(feedback.id) == nil
    end

    test "returns 404 for an unknown id" do
      conn = delete(professor_conn(), "/v1/feedbacks/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end

    test "returns 404 for a malformed id" do
      conn = delete(professor_conn(), "/v1/feedbacks/abc")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end
  end
end
