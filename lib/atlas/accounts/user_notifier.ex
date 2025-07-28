defmodule Atlas.Accounts.UserNotifier do
  @moduledoc """
  Provides methods to send notifications to users, such as confirmation instructions,
  password reset instructions, and email update instructions.
  """

  alias Atlas.Workers.EmailWorker
  # Enqueue the email using Oban
  defp deliver(recipient, subject, body) do
    job = %{
      "to" => recipient,
      "subject" => subject,
      "body" => body
    }

    Oban.insert!(EmailWorker.new(job))
    {:ok, :enqueued}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, path) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{build_full_url(path)}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, path) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{build_full_url(path)}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, path) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{build_full_url(path)}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  defp build_full_url(path) do
    base_url = Application.fetch_env!(:atlas, :frontend_url)
    "#{base_url}#{path}"
  end
end
