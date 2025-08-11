defmodule AtlasWeb.Router do
  use AtlasWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug RemoteIp
  end

  pipeline :auth do
    plug :accepts, ["json"]

    plug Guardian.Plug.Pipeline,
      otp_app: :atlas,
      error_handler: AtlasWeb.Plugs.AuthErrorHandler,
      module: Atlas.Accounts.Guardian

    plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
  end

  scope "/", AtlasWeb do
    get "/", PageController, :index
  end

  scope "/v1", AtlasWeb do
    pipe_through :api

    # Public routes

    scope "/auth" do
      post "/sign_in", AuthController, :sign_in
      post "/refresh", AuthController, :refresh_token
      post "/forgot_password", AuthController, :forgot_password
      post "/reset_password", AuthController, :reset_password
    end

    # Authenticated routes

    pipe_through :auth

    post "/users/:id/avatar", UserController, :upload_avatar
    delete "/users/:id/avatar", UserController, :delete_avatar

    scope "/auth" do
      post "/sign_out", AuthController, :sign_out
      get "/me", AuthController, :me
      get "/sessions", AuthController, :sessions
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
