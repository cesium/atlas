defmodule AtlasWeb.University.ShiftsControllerTest do
  use AtlasWeb.ConnCase

  alias Atlas.DegreesFixtures
  alias Atlas.University.Degrees.Courses.Shifts
  import Atlas.University.Degrees.Courses.ShiftsFixtures

  setup %{conn: _conn} do
    conn = AtlasWeb.ConnCase.authenticated_conn(%{type: :professor})
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists shifts with timeslots when course_id is provided", %{conn: conn} do
      degree = DegreesFixtures.degree_fixture()
      course1 = DegreesFixtures.course_fixture(%{degree_id: degree.id})
      course2 = DegreesFixtures.course_fixture(%{degree_id: degree.id})

      shift1 = shift_fixture(%{course_id: course1.id, number: 1, type: :theoretical})
      _shift2 = shift_fixture(%{course_id: course2.id, number: 1, type: :theoretical})

      _ts =
        timeslot_fixture(%{
          shift_id: shift1.id,
          weekday: :monday,
          start: ~T[09:00:00],
          end: ~T[11:00:00]
        })

      conn = get(conn, ~p"/v1/shifts?course_id=#{course1.id}")
      response = json_response(conn, 200)

      assert %{"data" => [returned_shift]} = response
      assert returned_shift["id"] == shift1.id
      assert returned_shift["number"] == 1
      assert returned_shift["type"] == "theoretical"
      assert length(returned_shift["timeslots"]) == 1
      assert hd(returned_shift["timeslots"])["weekday"] == "monday"
    end

    test "returns 400 bad request when course_id is missing or empty", %{conn: conn} do
      conn1 = get(conn, ~p"/v1/shifts")
      assert json_response(conn1, 400)["error"] =~ "Missing required query parameter: course_id"

      conn2 = get(conn, ~p"/v1/shifts?course_id=")
      assert json_response(conn2, 400)["error"] =~ "Missing required query parameter: course_id"
    end

    test "returns 403 forbidden when user is a student" do
      student_conn =
        AtlasWeb.ConnCase.authenticated_conn(%{type: :student})
        |> put_req_header("accept", "application/json")

      degree = DegreesFixtures.degree_fixture()
      course = DegreesFixtures.course_fixture(%{degree_id: degree.id})

      conn = get(student_conn, ~p"/v1/shifts?course_id=#{course.id}")
      assert json_response(conn, 403)
    end
  end

  describe "update shift" do
    test "updates shift and replaces timeslots", %{conn: conn} do
      shift = shift_fixture(%{professor: "Old Prof", number: 1})

      ts1 =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :monday,
          start: ~T[09:00:00],
          end: ~T[11:00:00]
        })

      ts2 =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :tuesday,
          start: ~T[14:00:00],
          end: ~T[16:00:00]
        })

      update_payload = %{
        "professor" => "New Prof",
        "number" => 2,
        "timeslots" => [
          %{
            "id" => ts1.id,
            "weekday" => "wednesday",
            "start" => "10:00",
            "end" => "12:00",
            "building" => "B1",
            "room" => "101"
          },
          %{
            "weekday" => "friday",
            "start" => "08:00",
            "end" => "10:00",
            "building" => "B2",
            "room" => "202"
          }
        ]
      }

      conn = put(conn, ~p"/v1/shifts/#{shift.id}", update_payload)
      assert %{"data" => updated_shift} = json_response(conn, 200)

      assert updated_shift["professor"] == "New Prof"
      assert updated_shift["number"] == 2
      assert length(updated_shift["timeslots"]) == 2

      timeslot_ids = Enum.map(updated_shift["timeslots"], & &1["id"])
      assert ts1.id in timeslot_ids
      refute ts2.id in timeslot_ids

      # Verify ts2 was deleted from database
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_timeslot!(ts2.id) end
    end

    test "partial update preserves existing timeslots when timeslots key is omitted", %{
      conn: conn
    } do
      shift = shift_fixture(%{professor: "Original Prof"})

      ts =
        timeslot_fixture(%{
          shift_id: shift.id,
          weekday: :monday,
          start: ~T[09:00:00],
          end: ~T[11:00:00]
        })

      conn = put(conn, ~p"/v1/shifts/#{shift.id}", %{"professor" => "Updated Solo Prof"})
      assert %{"data" => updated_shift} = json_response(conn, 200)

      assert updated_shift["professor"] == "Updated Solo Prof"
      assert length(updated_shift["timeslots"]) == 1
      assert hd(updated_shift["timeslots"])["id"] == ts.id
    end

    test "returns 422 unprocessable_entity when timeslot has end before start", %{conn: conn} do
      shift = shift_fixture()

      invalid_payload = %{
        "timeslots" => [
          %{
            "weekday" => "monday",
            "start" => "14:00",
            "end" => "10:00"
          }
        ]
      }

      conn = put(conn, ~p"/v1/shifts/#{shift.id}", invalid_payload)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 404 when shift id does not exist", %{conn: conn} do
      non_existent_id = Ecto.UUID.generate()

      assert_error_sent 404, fn ->
        put(conn, ~p"/v1/shifts/#{non_existent_id}", %{"professor" => "Ghost"})
      end
    end

    test "returns 403 forbidden when user is a student" do
      student_conn =
        AtlasWeb.ConnCase.authenticated_conn(%{type: :student})
        |> put_req_header("accept", "application/json")

      shift = shift_fixture()

      conn = put(student_conn, ~p"/v1/shifts/#{shift.id}", %{"professor" => "Hacker"})
      assert json_response(conn, 403)
    end
  end
end
