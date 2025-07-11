defmodule Atlas.Accounts.UserNotifier do
  @moduledoc """
  Provides methods to send notifications to users, such as confirmation instructions,
  password reset instructions, and email update instructions.
  """

  import Swoosh.Email

  alias Atlas.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Atlas", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
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
    base_url = System.get_env("FRONTEND_URL", "localhost:3000")
    "https://#{base_url}#{path}"
  end
end
