defmodule Atlas.ExchangeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Exchange` context.
  """

  @doc """
  Generate a shift_exchange_request.
  """
  def shift_exchange_request_fixture(attrs \\ %{}) do
    {:ok, shift_exchange_request} =
      attrs
      |> Enum.into(%{
        status: "some status"
      })
      |> Atlas.Exchange.create_shift_exchange_request()

    shift_exchange_request
  end
end
