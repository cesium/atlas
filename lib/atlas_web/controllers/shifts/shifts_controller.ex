defmodule AtlasWeb.ShiftsController do
  use AtlasWeb, :controller

  alias Atlas.University.Degrees.Courses.Shifts

  action_fallback AtlasWeb.FallbackController

  def index(conn, attrs) do
    {user, _} = Guardian.Plug.current_resource(conn)

    if user_has_elevated_privileges?(user) do
      shifts = Shifts.list_shifts(attrs)

      conn
      |> render(:index, shifts: shifts)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Unauthorized"})
    end
  end

  def update(conn, %{"id" => id} = attrs) do
    {user, _} = Guardian.Plug.current_resource(conn)
    shift = Shifts.get_shift!(id)

    if user_has_elevated_privileges?(user) do
      with {:ok, shift} <- Shifts.update_shift(shift, attrs) do
        render(conn, :show, shift: shift)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Unauthorized"})
    end
  end

  defp user_has_elevated_privileges?(user) do
    (user && user.type == :admin) || user.type == :professor
  end
end
