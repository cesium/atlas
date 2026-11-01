defmodule AtlasWeb.University.ShiftsController do
  use AtlasWeb, :controller
  alias Atlas.University.Degrees.Courses.Shifts

  action_fallback AtlasWeb.FallbackController

  def index(conn, attrs) do
    shifts = Shifts.list_shifts_with_timeslots(attrs)

    conn
    |> put_view(AtlasWeb.University.ShiftJSON)
    |> render(:index, shifts: shifts)
  end

  def update(conn, %{"id" => id} = attrs) do
    shift = Shifts.get_shift_with_timeslots(id)
    timeslot_attrs = Map.get(attrs, "timeslots", [])
    shift_attrs = Map.delete(attrs, "timeslots")

    case Shifts.update_shift_with_timeslots(shift, shift_attrs, timeslot_attrs) do
      {:ok, %{shift: updated_shift} = _results} ->
        conn
        |> put_view(AtlasWeb.University.ShiftJSON)
        |> render(:show, shift: updated_shift)

      {:error, _operation, changeset, _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: AtlasWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
