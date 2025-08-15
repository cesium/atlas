defmodule AtlasWeb.PreferencesController do
  use AtlasWeb, :controller
  use PhoenixSwagger

  alias Atlas.Accounts

  def get_language(conn, _params) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    language = Accounts.get_user_language(user.id)
    json(conn, %{language: language})
  end

  swagger_path :get_language do
    get("/v1/auth/language")
    summary("Get user language preference")
    description("Returns the current language preference for the authenticated user.")
    produces("application/json")
    tag("Preferences")
    operation_id("get_language")
    response(200, "Language preference returned successfully", Schema.ref(:LanguageResponse))
    security([%{Bearer: []}])
  end

  def update_language(conn, %{"language" => language}) do
    {user, _session} = Guardian.Plug.current_resource(conn)
    Accounts.set_user_language(user.id, language)
    json(conn, %{language: language})
  end

  def update_language(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Language parameter is required"})
  end

  swagger_path :update_language do
    post("/v1/auth/language")
    summary("Update user language preference")
    description("Updates the language preference for the authenticated user.")
    produces("application/json")
    consumes("application/json")
    tag("Preferences")
    operation_id("update_language")

    parameters do
      language_request(:body, Schema.ref(:LanguageRequest), "Language preference to set",
        required: true
      )
    end

    response(200, "Language preference updated successfully", Schema.ref(:LanguageResponse))
    response(400, "Bad request - Missing language parameter", Schema.ref(:ErrorResponse))
    security([%{Bearer: []}])
  end

  def available_languages(conn, _params) do
    json(conn, %{languages: ["pt-PT", "en-US"]})
  end

  swagger_path :available_languages do
    post("/v1/auth/available_languages")
    summary("Get available languages")
    description("Returns a list of all supported languages.")
    produces("application/json")
    tag("Preferences")
    operation_id("available_languages")

    response(
      200,
      "Available languages returned successfully",
      Schema.ref(:AvailableLanguagesResponse)
    )

    security([%{Bearer: []}])
  end

  def swagger_definitions do
    %{
      LanguageRequest:
        swagger_schema do
          title("LanguageRequest")
          description("Request schema for updating language preference")

          properties do
            language(:string, "Language", required: true, enum: ["pt-PT", "en-US"])
          end

          example(%{
            language: "en-US"
          })
        end,
      LanguageResponse:
        swagger_schema do
          title("LanguageResponse")
          description("Response schema for language preference")

          properties do
            language(:string, "Current language preference",
              required: true,
              enum: ["pt-PT", "en-US"]
            )
          end

          example(%{
            language: "en-US"
          })
        end,
      AvailableLanguagesResponse:
        swagger_schema do
          title("AvailableLanguagesResponse")
          description("Response schema for available languages")

          properties do
            languages(:array, "List of supported language codes",
              required: true,
              items: %{type: :string}
            )
          end

          example(%{
            languages: ["pt-PT", "en-US"]
          })
        end,
      ErrorResponse:
        swagger_schema do
          title("ErrorResponse")
          description("Error response schema")
          type(:object)

          properties do
            error(:string, "Error message", required: true)
          end

          example(%{
            error: "Language parameter is required"
          })
        end
    }
  end
end
