defmodule AtlasWeb.Router do
  use AtlasWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug :accepts, ["json"]

    plug Guardian.Plug.Pipeline,
      otp_app: :atlas,
      error_handler: AtlasWeb.Plugs.GuardianErrorHandler,
      module: Atlas.Accounts.Guardian

    plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/v1", AtlasWeb do
    pipe_through :api

    # Public routes

    scope "/auth" do
      post "/sign_in", AuthController, :sign_in
    end
  end

  scope "/v1", AtlasWeb do
    pipe_through [:api, :auth]

    # Authenticated routes

    scope "/auth" do
      get "/me", AuthController, :me
      post "/refresh", AuthController, :refresh_token
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:atlas, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AtlasWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
