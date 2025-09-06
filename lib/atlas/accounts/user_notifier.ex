defmodule Atlas.Accounts.UserNotifier do
  @moduledoc """
  Provides methods to send notifications to users, such as confirmation instructions,
  password reset instructions, and email update instructions.
  """

  import Swoosh.Email

  alias Atlas.Accounts
  alias Atlas.Mailer

  use Phoenix.Swoosh, view: AtlasWeb.EmailView

  use Gettext, backend: AtlasWeb.Gettext

  defp base_html_email(recipient, subject) do
    sender = {Mailer.get_sender_name(), Mailer.get_sender_address()}

    phx_host =
      if System.get_env("PHX_HOST") != nil do
        "https://" <> System.get_env("PHX_HOST")
      else
        ""
      end

    new()
    |> to(recipient)
    |> from(sender)
    |> subject("[#{elem(sender, 0)}] #{subject}")
    |> assign(:phx_host, phx_host)
  end

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
    url = build_full_url(path)

    set_gettext_language(user)

    email =
      base_html_email(user.email, "Confirm your email")
      |> assign(:user_name, user.name)
      |> assign(:confirm_email_link, url)
      |> render_body("confirm_email.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, path) do
    url = build_full_url(path)

    set_gettext_language(user)

    email =
      base_html_email(user.email, gettext("Reset your password"))
      |> assign(:user_name, user.name)
      |> assign(:reset_password_link, url)
      |> render_body("reset_password.html")

    case Mailer.deliver(email) do
      {:ok, _metadata} -> {:ok, email}
      {:error, reason} -> {:error, reason}
    end
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

  defp set_gettext_language(user) do
    language =
      case Accounts.get_user_preference(user.id, "language") do
        {:ok, nil} -> "pt_PT"
        {:ok, language} -> language |> String.replace("-", "_")
        {:error, _reason} -> "pt_PT"
      end

    Gettext.put_locale(AtlasWeb.Gettext, language)
  end
end
