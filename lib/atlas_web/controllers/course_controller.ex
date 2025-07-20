defmodule AtlasWeb.CourseController do
  alias Atlas.{Accounts, Degrees}

  use AtlasWeb, :controller

  action_fallback AtlasWeb.FallbackController

  def import_course_data(conn, %{"file" => %Plug.Upload{} = file}) do
    file_path = file.path

    case XlsxReader.open(file_path) do
      {:ok, package} ->
        sheets = XlsxReader.sheet_names(package)
        {:ok, rows} = XlsxReader.sheet(package, List.first(sheets))

        for row <- Enum.drop(rows, 7) do
          degree_code = Enum.at(row, 3)
          degree_name = Enum.at(row, 4)

          # Create the degree if it doesn't exist

          degree =
            Atlas.Degrees.get_degree_by_code(degree_code) ||
              case Degrees.create_degree(%{name: degree_name, code: degree_code}) do
                {:ok, created_degree} -> created_degree
                {:error, _changeset} -> nil
              end

          student_number = Enum.at(row, 11)
          name = Enum.at(row, 12)
          email = Enum.at(row, 13)
          special_status = Enum.at(row, 15)

          # Create the account if it doesn't exist

          user =
            Accounts.get_user_by_email(email) ||
              case Accounts.register_student_user_with_random_password(%{
                     name: name,
                     email: email,
                     student: %{
                       number: student_number,
                       degree_id: degree.id,
                       special_status: special_status
                     }
                   }) do
                {:ok, user} -> user
                {:error, _changeset} -> nil
              end
        end

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Failed to read the Excel file: #{reason}"})
    end

    conn
    |> put_status(:ok)
    |> json(%{message: "Course data import initiated"})
  end
end
