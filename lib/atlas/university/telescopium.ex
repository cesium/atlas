defmodule Atlas.University.Telescopium do
  @moduledoc """
  Telescopium context
  """

  def request_scrape_job(config \\ nil) do
    telescopium_api_url = Application.fetch_env!(:atlas, :telescopium_api_url)

    build_scrape_request(telescopium_api_url, config)
    |> Finch.request(Atlas.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_scrape_request(telescopium_api_url, nil) do
    Finch.build(:post, "#{telescopium_api_url}/scrape")
  end

  defp build_scrape_request(telescopium_api_url, config) do
    Finch.build(
      :post,
      "#{telescopium_api_url}/scrape",
      [{"Content-Type", "application/json"}],
      Jason.encode!(config)
    )
  end

  def fetch_result do
    telescopium_api_url = Application.fetch_env!(:atlas, :telescopium_api_url)

    Finch.build(:get, "#{telescopium_api_url}/shifts")
    |> Finch.request(Atlas.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode!(body) do
          %{"shifts" => shifts} ->
            {:ok, %{shifts: shifts}}

          %{"status" => status} ->
            {:ok, %{status: status}}

          other ->
            {:error, %{body: other}}
        end

      {:ok, %Finch.Response{status: 404, body: body}} ->
        {:error, Jason.decode!(body)["error"]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list_jobs do
    telescopium_api_url = Application.fetch_env!(:atlas, :telescopium_api_url)

    Finch.build(:get, "#{telescopium_api_url}/jobs")
    |> Finch.request(Atlas.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode!(body) do
          %{"jobs" => jobs} ->
            {:ok, %{jobs: jobs}}

          other ->
            {:error, %{body: other}}
        end

      {:ok, %Finch.Response{status: 404, body: body}} ->
        {:error, Jason.decode!(body)["error"]}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
