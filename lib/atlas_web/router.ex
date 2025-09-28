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

  pipeline :is_at_least_professor do
    plug AtlasWeb.Plugs.UserRequires, user_types: [:professor, :admin]
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

    scope "/auth" do
      post "/sign_out", AuthController, :sign_out
      get "/me", AuthController, :me
      get "/sessions", AuthController, :sessions
      post "/update_password", AuthController, :update_password
    end

    scope "/preferences" do
      get "/", PreferencesController, :get_preferences
      get "/available", PreferencesController, :get_available_preferences
      get "/:preference", PreferencesController, :get_preference
      put "/", PreferencesController, :update_preferences
    end

    scope "/courses", University do
      get "/", CourseController, :index
    end

    scope "/degrees", University do
      get "/", DegreeController, :index
    end

    scope "/student", University do
      get "/schedule", StudentsController, :schedule_index
      post "/schedule", StudentsController, :schedule_update
    end

    scope "/shift_exchanges" do
      scope "/exchange_period" do
        get "/", ShiftExchangeRequestController, :get_exchange_period

        pipe_through :is_at_least_professor

        post "/", ShiftExchangeRequestController, :set_exchange_period
        delete "/", ShiftExchangeRequestController, :delete_exchange_period
      end

      resources "/", ShiftExchangeRequestController, only: [:index, :create, :show, :delete]
    end

    resources "/feedbacks", FeedbacksController, except: [:new, :edit, :show]

    pipe_through :is_at_least_professor

    scope "/jobs" do
      get "/", JobController, :index
      get "/:id", JobController, :show
    end

    scope "/schedule", University do
      post "/generate", ScheduleController, :generate_schedule
      post "/build_request", ScheduleController, :build_schedule_generation_request
      post "/import_schedule_result", ScheduleController, :import_schedule_result
    end

    scope "/import" do
      post "/students_by_courses", ImportController, :students_by_courses
      post "/shifts_by_courses", ImportController, :shifts_by_courses
    end

    scope "/export" do
      scope "/blackboard" do
        get "/:course_id/groups", ExportController, :blackboard_groups_export

        get "/:course_id/group_enrollments",
            ExportController,
            :blackboard_group_enrollments_export
      end
    end

    scope "/statistics" do
      get "/course_shifts_capacity/:course_id", StatisticsController, :course_shifts_capacity
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
