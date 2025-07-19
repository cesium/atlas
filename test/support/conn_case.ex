defmodule AtlasWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.
  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AtlasWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """
  @endpoint AtlasWeb.Endpoint

  require Phoenix.ConnTest
  use ExUnit.CaseTemplate

  alias Atlas.Accounts.Guardian, as: AccountsGuardian
  alias Atlas.AccountsFixtures
  alias Guardian.Plug.{EnsureAuthenticated, LoadResource, Pipeline, VerifyHeader}
  alias Phoenix.ConnTest
  alias Plug.Conn

  using do
    quote do
      # The default endpoint for testing
      @endpoint AtlasWeb.Endpoint

      use AtlasWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AtlasWeb.ConnCase
    end
  end

  setup tags do
    Atlas.DataCase.setup_sandbox(tags)
    {:ok, conn: ConnTest.build_conn()}
  end

  @doc """
  Helper function to create an authenticated connection.
  It simulates a user signing in and returns a connection with the user's access_token.
  """
  def authenticated_conn(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture(attrs)

    login_conn =
      ConnTest.post(ConnTest.build_conn(), "/v1/auth/sign_in", %{
        "email" => user.email,
        "password" => AccountsFixtures.valid_user_password()
      })

    {:ok, %{"access_token" => access_token}} = Jason.decode(login_conn.resp_body)

    ConnTest.build_conn()
    |> Conn.put_req_header("authorization", "Bearer #{access_token}")
    |> Pipeline.call(Pipeline.init(module: AccountsGuardian))
    |> VerifyHeader.call(VerifyHeader.init([]))
    |> EnsureAuthenticated.call(EnsureAuthenticated.init([]))
    |> LoadResource.call(LoadResource.init([]))
  end
end
