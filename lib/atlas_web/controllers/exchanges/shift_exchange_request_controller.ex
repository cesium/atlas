defmodule AtlasWeb.ShiftExchangeRequestController do
  use AtlasWeb, :controller

  alias Atlas.Exchange
  alias Atlas.Repo

  action_fallback AtlasWeb.FallbackController

  def index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    shift_exchange_requests =
      if user_has_elevated_privileges?(user) do
        Exchange.list_shift_exchange_requests()
      else
        Exchange.list_shift_exchange_requests(where: [student_id: user.student.id])
      end

    render(conn, :index,
      shift_exchange_requests:
        shift_exchange_requests |> Repo.preload(from: [:timeslots], to: [:timeslots])
    )
  end

  def show(conn, %{"id" => id}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    request =
      Exchange.get_shift_exchange_request!(id)
      |> Repo.preload(from: [:timeslots], to: [:timeslots])

    if request.student_id != user.student.id and not user_has_elevated_privileges?(user) do
      conn
      |> put_status(:not_found)
      |> json(%{errors: %{"detail" => "Not found"}})
    else
      render(conn, :show, shift_exchange_request: request)
    end
  end

  def create(conn, %{"request" => shift_exchange_request}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    if user.type == :student do
      with {:ok, request} <-
             shift_exchange_request
             |> Map.put("student_id", user.student.id)
             |> Exchange.create_shift_exchange_request() do
        conn
        |> put_status(:created)
        |> render(:show,
          shift_exchange_request: request |> Repo.preload(from: [:timeslots], to: [:timeslots])
        )
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Only students can create shift exchange requests"})
    end
  end

  def delete(conn, %{"id" => id}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    request = Exchange.get_shift_exchange_request!(id)

    if request.student_id != user.student.id and not user_has_elevated_privileges?(user) do
      conn
      |> put_status(:not_found)
      |> json(%{errors: %{"detail" => "Not found"}})
    else
      if request.status != :pending do
        conn
        |> put_status(:forbidden)
        |> json(%{errors: %{"detail" => "Only pending requests can be deleted"}})
      else
        with {:ok, %Exchange.ShiftExchangeRequest{}} <-
               Exchange.delete_shift_exchange_request(request) do
          send_resp(conn, :no_content, "")
        end
      end
    end
  end

  defp user_has_elevated_privileges?(user) do
    (user && user.type == :admin) || user.type == :professor
  end
end
