defmodule Atlas.UserRequiresTest do
  use AtlasWeb.ConnCase

  setup do
    %{
      student_conn: authenticated_conn(%{type: :student}),
      admin_conn: authenticated_conn(%{type: :admin}),
      professor_conn: authenticated_conn(%{type: :professor})
    }
  end

  describe "authorized access" do
    test "student accessing student route", %{student_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :student))
      assert_authorized(conn)
    end

    test "admin accessing admin route", %{admin_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :admin))
      assert_authorized(conn)
    end

    test "professor accessing professor route", %{professor_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :professor))
      assert_authorized(conn)
    end

    test "student accessing open route", %{student_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_types: [:student, :admin, :professor]))
      assert_authorized(conn)
    end
  end

  describe "unauthorized access" do
    test "student accessing admin route", %{student_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :admin))
      assert_unauthorized(conn)
    end

    test "admin accessing student route", %{admin_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :student))
      assert_unauthorized(conn)
    end

    test "professor accessing restricted route", %{professor_conn: conn} do
      conn = AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_types: [:student, :admin]))
      assert_unauthorized(conn)
    end
  end

  describe "edge cases" do
    test "raises error when no user_type or user_types provided" do
      assert_raise ArgumentError, "You must provide either the :user_type or :user_types option", fn ->
        AtlasWeb.Plugs.UserRequires.init([])
      end
    end

    test "handles nil user" do
      conn = build_conn()
      |> Guardian.Plug.Pipeline.call(Guardian.Plug.Pipeline.init(module: Atlas.Accounts.Guardian))

      assert_raise MatchError, fn ->
        AtlasWeb.Plugs.UserRequires.call(conn, AtlasWeb.Plugs.UserRequires.init(user_type: :admin))
      end
    end
  end

  defp assert_unauthorized(conn) do
    assert conn.halted == true
    assert conn.status == 403
    assert json_response(conn, 403)["error"] == "Unauthorized"
  end

  defp assert_authorized(conn) do
    assert conn.halted == false
    assert conn.status == nil
  end

end
