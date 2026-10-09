defmodule AtlasWeb.University.ClassesPeriodController do
  use AtlasWeb, :controller

  alias Atlas.University

  def get_classes_period(conn, %{"semester" => semester_param}) do
    case parse_semester(semester_param) do
      {:ok, semester} ->
        case University.get_classes_period(semester) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "No classes period set for semester #{semester}"})

          period ->
            conn
            |> put_status(:ok)
            |> json(period)
        end

      {:error, :invalid_semester} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid semester. Expected 1 or 2"})
    end
  end

  def set_classes_period(conn, %{
        "semester" => semester_param,
        "start" => start_str,
        "end" => end_str
      }) do
    with {:ok, semester} <- parse_semester(semester_param),
         {:ok, start_time, _} <- DateTime.from_iso8601(start_str),
         {:ok, end_time, _} <- DateTime.from_iso8601(end_str),
         {:ok, _period} <- University.set_classes_period(semester, start_time, end_time) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Classes period for semester #{semester} set successfully"})
    else
      {:error, :invalid_semester} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid semester. Expected 1 or 2"})

      {:error, :invalid_format} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid datetime format"})

      {:error, reason} when is_binary(reason) ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid request parameters"})
    end
  end

  def set_classes_period(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing start or end datetime parameters"})
  end

  def delete_classes_period(conn, %{"semester" => semester_param}) do
    case parse_semester(semester_param) do
      {:ok, semester} ->
        University.delete_classes_period(semester)

        conn
        |> send_resp(:no_content, "")

      {:error, :invalid_semester} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid semester. Expected 1 or 2"})
    end
  end

  defp parse_semester(semester) when is_integer(semester) and semester in [1, 2],
    do: {:ok, semester}

  defp parse_semester(semester) when is_binary(semester) do
    case Integer.parse(semester) do
      {sem, ""} when sem in [1, 2] -> {:ok, sem}
      _ -> {:error, :invalid_semester}
    end
  end

  defp parse_semester(_), do: {:error, :invalid_semester}
end
