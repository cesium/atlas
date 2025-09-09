defmodule AtlasWeb.ShiftExchangeRequestController do
  use AtlasWeb, :controller

  alias Atlas.{Exchange, Repo}

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
        shift_exchange_requests
        |> Repo.preload(from: [:timeslots, :course], to: [:timeslots, :course])
    )
  end

  def show(conn, %{"id" => id}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    request =
      Exchange.get_shift_exchange_request!(id)
      |> Repo.preload(from: [:timeslots, :course], to: [:timeslots, :course])

    if request.student_id != user.student.id and not user_has_elevated_privileges?(user) do
      conn
      |> put_status(:not_found)
      |> json(%{errors: %{"detail" => "Not found"}})
    else
      render(conn, :show, shift_exchange_request: request)
    end
  end

  def create(conn, %{"request" => shift_exchange_request}) do
    if Exchange.exchange_period_active?() do
      {user, _session} = Guardian.Plug.current_resource(conn)

      if user.type == :student do
        with {:ok, request} <-
               shift_exchange_request
               |> Map.put("student_id", user.student.id)
               |> Exchange.create_shift_exchange_request() do
          conn
          |> put_status(:created)
          |> render(:show,
            shift_exchange_request:
              request |> Repo.preload(from: [:timeslots, :course], to: [:timeslots, :course])
          )
        end
      else
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Only students can create shift exchange requests"})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Shift exchange requests can only be created during the exchange period"})
    end
  end

  def delete(conn, %{"id" => id}) do
    if Exchange.exchange_period_active?() do
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
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Shift exchange requests can only be deleted during the exchange period"})
    end
  end

  def get_exchange_period(conn, _params) do
    case Exchange.get_exchange_period() do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No exchange period set"})

      period ->
        conn
        |> put_status(:ok)
        |> json(period)
    end
  end

  def set_exchange_period(conn, %{"start" => start_str, "end" => end_str}) do
    with {:ok, start_time, _} <- DateTime.from_iso8601(start_str),
         {:ok, end_time, _} <- DateTime.from_iso8601(end_str),
         {:ok, _period} <- Exchange.set_exchange_period(start_time, end_time) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Exchange period set successfully"})
    else
      {:error, :invalid_format} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid datetime format"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  def delete_exchange_period(conn, _params) do
    Exchange.delete_exchange_period()

    conn
    |> send_resp(:no_content, "")
  end

  defp user_has_elevated_privileges?(user) do
    (user && user.type == :admin) || user.type == :professor
  end
end
