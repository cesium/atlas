defmodule Atlas.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Atlas.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "User Name",
      email: unique_user_email(),
      password: valid_user_password(),
      type: :student
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Atlas.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    fun.(fn token -> "[TOKEN]#{token}[TOKEN]" end)
    {:email, email_struct} = Swoosh.TestAssertions.assert_email_sent()
    [_, token | _] = String.split(email_struct.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a user_session.
  """
  def user_session_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        ip: "some ip",
        user_agent: "some user_agent",
        user_os: "some user_os",
        user_browser: "some user_browser"
      })

    {:ok, user_session} =
      user_fixture()
      |> Atlas.Accounts.create_user_session(
        attrs.ip,
        attrs.user_agent,
        attrs.user_os,
        attrs.user_browser
      )

    user_session
  end
end
