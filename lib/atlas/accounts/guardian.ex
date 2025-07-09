defmodule Atlas.Accounts.Guardian do
  @moduledoc """
  Guardian implementation for application accounts.
  """
  use Guardian, otp_app: :atlas

  alias Atlas.Accounts
  alias Atlas.Accounts.{User, UserSession}

  @impl true
  def subject_for_token({%User{id: _user_id}, %UserSession{id: session_id}}, _claims) do
    {:ok, session_id}
  end

  def subject_for_token(_, _claims) do
    {:error, :invalid_resource}
  end

  @impl true
  def resource_from_claims(%{"sub" => session_id}) do
    case Accounts.get_user_session(session_id) do
      nil ->
        {:error, :not_found}

      session ->
        {:ok, {session.user, session}}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :invalid_claims}
  end

  @impl true
  def after_encode_and_sign(resource, claims, token, _options) do
    {_user, session} = resource

    with {:ok, _} <- Guardian.DB.after_encode_and_sign(session.id, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  @impl true
  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  @impl true
  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  @impl true
  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
