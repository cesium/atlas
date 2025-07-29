defmodule Atlas.Workers.EmailWorker do
  @moduledoc """
  Oban worker responsible for sending emails asynchronously using the application's mailer.
  """
  use Oban.Worker, queue: :emails

  require Logger

  import Swoosh.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"to" => to, "subject" => subject, "body" => body}}) do
    required = [to, subject, body]

    if Enum.any?(required, &nil_or_blank?/1) do
      Logger.warning("Email not sent: missing required fields")
      :discard
    else
      email =
        new()
        |> from({"Atlas", "contact@example.com"})
        |> to(to)
        |> subject(subject)
        |> text_body(body)

      case Atlas.Mailer.deliver(email) do
        {:ok, _metadata} ->
          Logger.info("Email sent to #{to}")
          :ok

        {:error, reason} ->
          Logger.error("Failed to send email to #{to}: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  defp nil_or_blank?(val), do: is_nil(val) or (is_binary(val) and String.trim(val) == "")
end
