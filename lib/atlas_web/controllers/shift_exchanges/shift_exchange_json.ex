defmodule AtlasWeb.ShiftExchangeRequestJSON do
  @moduledoc """
  A module for rendering shift exchange request data in JSON format.
  """

  @doc """
  Renders a list of shift exchange requests as JSON.
  """
  def index(%{shift_exchange_requests: shift_exchange_requests}) do
    %{requests: for(shift_exchange_request <- shift_exchange_requests, do: data(shift_exchange_request))}
  end

  @doc """
  Renders a single shift exchange request as JSON.
  """
  def show(%{shift_exchange_request: shift_exchange_request}) do
    %{request: data(shift_exchange_request)}
  end

  @doc """
  Renders a shift exchange request as JSON.
  """
  def data(shift_exchange_request) do
    %{
      status: shift_exchange_request.status,
      from: shift_exchange_request.from,
      to: shift_exchange_request.to,
      inserted_at: shift_exchange_request.inserted_at
    }
  end
end
