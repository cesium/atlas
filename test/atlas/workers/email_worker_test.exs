defmodule Atlas.Workers.EmailWorkerTest do
  use Atlas.DataCase, async: true

  import Swoosh.TestAssertions
  alias Atlas.Workers.EmailWorker

  test "enqueues and delivers email job" do
    job = %{
      "to" => "test@example.com",
      "subject" => "Queued Email",
      "body" => "Hello from Oban!"
    }

    assert {:ok, _job} = Oban.insert(EmailWorker.new(job))

    assert_email_sent(
      to: {nil, "test@example.com"},
      subject: "Queued Email",
      text_body: "Hello from Oban!"
    )
  end

  test "does not deliver email with missing fields" do
    job = %{"to" => nil, "subject" => nil, "body" => nil}
    assert {:ok, _job} = Oban.insert(EmailWorker.new(job))
    refute_email_sent()
  end

  test "enqueues and delivers multiple email jobs" do
    jobs = [
      %{"to" => "a@example.com", "subject" => "A", "body" => "Body A"},
      %{"to" => "b@example.com", "subject" => "B", "body" => "Body B"}
    ]

    Enum.each(jobs, fn job ->
      assert {:ok, _job} = Oban.insert(EmailWorker.new(job))
    end)

    assert_email_sent(to: {nil, "a@example.com"}, subject: "A", text_body: "Body A")
    assert_email_sent(to: {nil, "b@example.com"}, subject: "B", text_body: "Body B")
  end
end
