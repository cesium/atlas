defmodule AtlasWeb.ShiftsController do
  use AtlasWeb, :controller

  alias Atlas.Repo
  alias Atlas.University.Degrees.Courses.Shifts

  action_fallback AtlasWeb.FallbackController

  def index(conn, attrs) do
    {user, _} = Guardian.Plug.current_resource(conn)

    if user_has_elevated_privileges?(user) do
      shifts = Shifts.list_shifts_with_timeslots(attrs)

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

    if user_has_elevated_privileges?(user) do
      shift = Shifts.get_shift_with_timeslots(id)
      timeslot_attrs = Map.get(attrs, "timeslots", [])
      shift_attrs = Map.delete(attrs, "timeslots")

      case Shifts.update_shift_with_timeslots(shift, shift_attrs, timeslot_attrs) do
        {:ok, %{shift: updated_shift} = _results} ->
          conn
          |> render(:show, shift: updated_shift |> Repo.preload([:timeslots]))

        {:error, _operation, changeset, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> put_view(json: AtlasWeb.ChangesetJSON)
          |> render(:error, changeset: changeset)
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
