
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
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Helper function to create an authenticated connection.
  It simulates a user signing in and returns a connection with the user's access_token.
  """
  def authenticated_conn(attrs \\ %{}) do
    user = Atlas.AccountsFixtures.user_fixture(attrs)
    login_conn = Phoenix.ConnTest.post(Phoenix.ConnTest.build_conn(), "/v1/auth/sign_in", %{
      "email" => user.email,
      "password" => Atlas.AccountsFixtures.valid_user_password()
    })

    {:ok, %{"access_token" => access_token}} = Jason.decode(login_conn.resp_body)

    Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("authorization", "Bearer #{access_token}")
    |> Guardian.Plug.Pipeline.call(Guardian.Plug.Pipeline.init([module: Atlas.Accounts.Guardian]))
    |> Guardian.Plug.VerifyHeader.call(Guardian.Plug.VerifyHeader.init([]))
    |> Guardian.Plug.EnsureAuthenticated.call(Guardian.Plug.EnsureAuthenticated.init([]))
    |> Guardian.Plug.LoadResource.call(Guardian.Plug.LoadResource.init([]))
  end
end
