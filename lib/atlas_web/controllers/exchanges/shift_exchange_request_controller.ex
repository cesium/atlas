defmodule AtlasWeb.ShiftExchangeRequestController do
  use AtlasWeb, :controller

  alias Atlas.{Exchange, Workers}

  action_fallback AtlasWeb.FallbackController

  def index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    shift_exchange_requests =
      if user_can_list_all_exchanges?(user) do
        Exchange.list_shift_exchange_requests()
      else
        Exchange.list_shift_exchange_requests(where: [student_id: user.student.id])
      end

    render(conn, :index, shift_exchange_requests: shift_exchange_requests)
  end

  def create(conn, %{"request" => shift_exchange_request}) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    case Exchange.create_shift_exchange_request(
           shift_exchange_request
           |> Map.put(:student_id, user.student.id)
         ) do
      {:ok, request} ->
        conn
        |> put_status(:created)
        |> render(:show, shift_exchange_request: request)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Could not create shift exchange request: #{reason}"})
    end
  end

  defp user_can_list_all_exchanges?(user) do
    (user && user.type == :admin) || user.type == :professor
  end
end
