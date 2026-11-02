defmodule Atlas.Workers.SyncTimeslotsTest do
  use Atlas.DataCase, async: true

  alias Atlas.Constants
  alias Atlas.Workers.SyncTimeslots

  test "skips cron syncs when auto sync is disabled" do
    assert {:ok, _pair} = Constants.set("auto_sync", false)

    job = %Oban.Job{args: %{}, meta: %{"cron" => true}}

    assert :ok = SyncTimeslots.perform(job)
  end
end
