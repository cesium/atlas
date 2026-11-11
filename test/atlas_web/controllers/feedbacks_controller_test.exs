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

  defp create_feedback(user_id, inserted_at) do
    user_id
    |> create_feedback()
    |> Ecto.Changeset.change(inserted_at: inserted_at)
    |> Atlas.Repo.update!()
  end

  defp admin_conn, do: authenticated_conn(%{type: :admin})

  describe "create" do
    test "creates feedback for the current user with a long message" do
      conn = authenticated_conn()
      message = String.duplicate("x", 1000)

      conn = post(conn, "/v1/feedbacks", %{"subject" => "Bug", "message" => message})

      assert %{
               "data" => %{
                 "id" => _,
                 "subject" => "Bug",
                 "message" => ^message,
                 "user" => %{"name" => "User Name"}
               }
             } = json_response(conn, 201)
    end

    test "ignores a user_id sent in the body" do
      conn = authenticated_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      other_user = Atlas.AccountsFixtures.user_fixture()

      conn =
        post(conn, "/v1/feedbacks", %{
          "subject" => "Bug",
          "message" => "m",
          "user_id" => other_user.id
        })

      assert %{"data" => %{"user" => %{"id" => user_id}}} = json_response(conn, 201)
      assert user_id == user.id
    end

    test "returns per-field errors when fields are missing" do
      conn = post(authenticated_conn(), "/v1/feedbacks", %{})

      assert %{"errors" => %{"subject" => [_], "message" => [_]}} = json_response(conn, 422)
    end

    test "returns a field error when message is too long" do
      conn =
        post(authenticated_conn(), "/v1/feedbacks", %{
          "subject" => "Bug",
          "message" => String.duplicate("m", 5001)
        })

      assert %{"errors" => %{"message" => [_]}} = json_response(conn, 422)
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

  describe "index" do
    test "lists feedbacks with their user" do
      conn = admin_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      create_feedback(user.id)

      conn = get(conn, "/v1/feedbacks")

      assert %{"data" => [%{"user" => %{"id" => user_id, "name" => "User Name"}}]} =
               json_response(conn, 200)

      assert user_id == user.id
    end

    test "returns the newest feedbacks first with pagination meta" do
      conn = admin_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)

      older = create_feedback(user.id, ~U[2026-01-01 10:00:00Z])
      newer = create_feedback(user.id, ~U[2026-02-01 10:00:00Z])

      conn = get(conn, "/v1/feedbacks")

      assert %{"data" => [%{"id" => first_id}, %{"id" => second_id}], "meta" => meta} =
               json_response(conn, 200)

      assert [first_id, second_id] == [newer.id, older.id]
      assert %{"current_page" => 1, "page_size" => 20, "total_entries" => 2} = meta
    end

    test "paginates with page and page_size" do
      conn = admin_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      for _ <- 1..3, do: create_feedback(user.id)

      conn = get(conn, "/v1/feedbacks", %{"page" => 2, "page_size" => 2})

      assert %{
               "data" => [_],
               "meta" => %{"current_page" => 2, "total_pages" => 2, "has_next_page" => false}
             } = json_response(conn, 200)
    end

    test "returns 400 for invalid pagination params" do
      conn = get(admin_conn(), "/v1/feedbacks", %{"page" => -1})

      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)
    end

    test "is forbidden for professors" do
      conn = get(authenticated_conn(%{type: :professor}), "/v1/feedbacks")

      assert json_response(conn, 403) == %{"error" => "Unauthorized"}
    end

    test "is forbidden for students" do
      conn = get(authenticated_conn(), "/v1/feedbacks")

      assert json_response(conn, 403) == %{"error" => "Unauthorized"}
    end
  end

  describe "show" do
    test "returns the feedback" do
      conn = admin_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      feedback = create_feedback(user.id)

      conn = get(conn, "/v1/feedbacks/#{feedback.id}")

      assert %{"data" => %{"id" => id}} = json_response(conn, 200)
      assert id == feedback.id
    end

    test "returns 404 for an unknown id" do
      conn = get(admin_conn(), "/v1/feedbacks/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end

    test "returns 404 for a malformed id" do
      conn = get(admin_conn(), "/v1/feedbacks/abc")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end
  end

  describe "delete" do
    test "deletes the feedback" do
      conn = admin_conn()
      {user, _session} = Guardian.Plug.current_resource(conn)
      feedback = create_feedback(user.id)

      conn = delete(conn, "/v1/feedbacks/#{feedback.id}")

      assert response(conn, 204)
      assert Feedbacks.get_feedback(feedback.id) == nil
    end

    test "returns 404 for an unknown id" do
      conn = delete(admin_conn(), "/v1/feedbacks/#{Ecto.UUID.generate()}")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end

    test "returns 404 for a malformed id" do
      conn = delete(admin_conn(), "/v1/feedbacks/abc")

      assert json_response(conn, 404) == %{"error" => "Feedback not found"}
    end
  end
end
