defmodule AtlasWeb.University.ClassesPeriodControllerTest do
  use AtlasWeb.ConnCase

  alias Atlas.University

  setup do
    on_exit(fn ->
      University.delete_classes_period(1)
      University.delete_classes_period(2)
    end)

    prof_conn =
      AtlasWeb.ConnCase.authenticated_conn(%{type: :professor})
      |> put_req_header("accept", "application/json")

    student_conn =
      AtlasWeb.ConnCase.authenticated_conn(%{type: :student})
      |> put_req_header("accept", "application/json")

    %{prof_conn: prof_conn, student_conn: student_conn}
  end

  describe "get_classes_period/2" do
    test "returns 404 when no period is set", %{student_conn: conn} do
      conn = get(conn, ~p"/v1/classes_period/1")
      assert json_response(conn, 404)["error"] =~ "No classes period set"
    end

    test "returns 200 when period is set", %{prof_conn: prof_conn, student_conn: student_conn} do
      start_time = ~U[2024-09-16 00:00:00Z]
      end_time = ~U[2024-12-20 23:59:59Z]
      {:ok, _} = University.set_classes_period(1, start_time, end_time)

      conn = get(student_conn, ~p"/v1/classes_period/1")
      response = json_response(conn, 200)

      assert response["start"] != nil
      assert response["end"] != nil
    end

    test "returns 400 for invalid semester", %{student_conn: conn} do
      conn = get(conn, ~p"/v1/classes_period/3")
      assert json_response(conn, 400)["error"] =~ "Invalid semester"
    end
  end

  describe "set_classes_period/2" do
    test "sets classes period when user is professor", %{prof_conn: conn} do
      params = %{
        "start" => "2024-09-16T00:00:00Z",
        "end" => "2024-12-20T23:59:59Z"
      }

      conn = post(conn, ~p"/v1/classes_period/1", params)

      assert json_response(conn, 200)["message"] =~
               "Classes period for semester 1 set successfully"

      period = University.get_classes_period(1)
      assert period.start != nil
      assert period.end != nil
    end

    test "returns 400 when start time is after end time", %{prof_conn: conn} do
      params = %{
        "start" => "2024-12-21T00:00:00Z",
        "end" => "2024-09-16T00:00:00Z"
      }

      conn = post(conn, ~p"/v1/classes_period/1", params)
      assert json_response(conn, 400)["error"] =~ "Start time must be before end time"
    end

    test "returns 403 when user is student", %{student_conn: conn} do
      params = %{
        "start" => "2024-09-16T00:00:00Z",
        "end" => "2024-12-20T23:59:59Z"
      }

      conn = post(conn, ~p"/v1/classes_period/1", params)
      assert response(conn, 403)
    end
  end

  describe "delete_classes_period/2" do
    test "deletes classes period when user is professor", %{
      prof_conn: prof_conn,
      student_conn: student_conn
    } do
      {:ok, _} =
        University.set_classes_period(1, ~U[2024-09-16 00:00:00Z], ~U[2024-12-20 23:59:59Z])

      conn = delete(prof_conn, ~p"/v1/classes_period/1")
      assert response(conn, 204)

      conn = get(student_conn, ~p"/v1/classes_period/1")
      assert json_response(conn, 404)
    end

    test "returns 403 when user is student", %{student_conn: conn} do
      conn = delete(conn, ~p"/v1/classes_period/1")
      assert response(conn, 403)
    end
  end
end
