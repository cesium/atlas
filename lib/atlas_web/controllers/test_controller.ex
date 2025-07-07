defmodule AtlasWeb.TestController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  swagger_path :index do
    get("/api/test")
    summary("Health check")
    description("Returns a simple OK message.")
    produces("application/json")
    response(200, "Success", Schema.ref(:HealthResponse))
  end

  def index(conn, _params) do
    json(conn, %{message: "ok"})
  end

  def swagger_definitions do
    %{
      HealthResponse: swagger_schema do
        title("HealthCheck")
        description("Simple response to confirm service is alive")
        properties do
          message(:string, "Confirmation message")
        end
        example(%{message: "ok"})
      end
    }
  end
end
