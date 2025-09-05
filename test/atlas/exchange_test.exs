defmodule Atlas.ExchangeTest do
  use Atlas.DataCase

  alias Atlas.Exchange

  describe "shift_exchange_requests" do
    alias Atlas.Exchange.ShiftExchangeRequest

    import Atlas.ExchangeFixtures

    @invalid_attrs %{status: nil}

    test "list_shift_exchange_requests/0 returns all shift_exchange_requests" do
      shift_exchange_request = shift_exchange_request_fixture()
      assert Exchange.list_shift_exchange_requests() == [shift_exchange_request]
    end

    test "get_shift_exchange_request!/1 returns the shift_exchange_request with given id" do
      shift_exchange_request = shift_exchange_request_fixture()

      assert Exchange.get_shift_exchange_request!(shift_exchange_request.id) ==
               shift_exchange_request
    end

    test "create_shift_exchange_request/1 with valid data creates a shift_exchange_request" do
      valid_attrs = %{status: "some status"}

      assert {:ok, %ShiftExchangeRequest{} = shift_exchange_request} =
               Exchange.create_shift_exchange_request(valid_attrs)

      assert shift_exchange_request.status == "some status"
    end

    test "create_shift_exchange_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchange.create_shift_exchange_request(@invalid_attrs)
    end

    test "update_shift_exchange_request/2 with valid data updates the shift_exchange_request" do
      shift_exchange_request = shift_exchange_request_fixture()
      update_attrs = %{status: "some updated status"}

      assert {:ok, %ShiftExchangeRequest{} = shift_exchange_request} =
               Exchange.update_shift_exchange_request(shift_exchange_request, update_attrs)

      assert shift_exchange_request.status == "some updated status"
    end

    test "update_shift_exchange_request/2 with invalid data returns error changeset" do
      shift_exchange_request = shift_exchange_request_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Exchange.update_shift_exchange_request(shift_exchange_request, @invalid_attrs)

      assert shift_exchange_request ==
               Exchange.get_shift_exchange_request!(shift_exchange_request.id)
    end

    test "delete_shift_exchange_request/1 deletes the shift_exchange_request" do
      shift_exchange_request = shift_exchange_request_fixture()

      assert {:ok, %ShiftExchangeRequest{}} =
               Exchange.delete_shift_exchange_request(shift_exchange_request)

      assert_raise Ecto.NoResultsError, fn ->
        Exchange.get_shift_exchange_request!(shift_exchange_request.id)
      end
    end

    test "change_shift_exchange_request/1 returns a shift_exchange_request changeset" do
      shift_exchange_request = shift_exchange_request_fixture()
      assert %Ecto.Changeset{} = Exchange.change_shift_exchange_request(shift_exchange_request)
    end
  end
end
