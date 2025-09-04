defmodule AtlasWeb.ShiftExchangesController do
  use AtlasWeb, :controller

  alias Atlas.{Exchange, Workers}

  action_fallback AtlasWeb.FallbackController

  def index(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)

    shift_exchanges =
      if user_can_list_all_exchanges?(user) do
        Exchange.list_shift_exchange_requests()
      else
        Exchange.list_shift_exchange_requests(where: [student_id: user.student.id])
      end

    render(conn, :index, shift_exchanges: shift_exchanges)
  end

  defp user_can_list_all_exchanges?(user) do
    user && user.type == :admin || user.type == :professor
  end
end
