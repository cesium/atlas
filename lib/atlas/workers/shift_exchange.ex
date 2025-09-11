defmodule Atlas.Workers.ShiftExchange do
  @moduledoc """
  Worker to handle shift exchange requests.
  """
  use Oban.Worker, queue: :exchanges

  alias Atlas.Exchange

  @impl Oban.Worker
  def perform(_job) do
    Exchange.solve_exchanges()

    :ok
  end
end
