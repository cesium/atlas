defmodule AtlasWeb.Plugs.RateLimiter do
  @moduledoc """
  A Plug for rate limiting requests by IP address and user ID using Hammer.

  ## How It Works

  - Limits **IP addresses** to `# {@ip_limit}` requests per `# {@interval}` ms.
  - Limits **authenticated users** (via `conn.assigns[:current_user_id]`) to `# {@user_limit}` requests per `# {@interval}` ms.
  - If either limit is exceeded, the request is halted with a `429 Too Many Requests` response.

  This plug expects `conn.assigns[:current_user_id]` to be set by an authentication plug earlier in the pipeline.
  If not present, the plug will default to treating the user as `"anon"`.
  """

  import Plug.Conn
  alias Hammer

  @ip_limit 100
  @user_limit 60
  @interval 60_000

  def init(opts), do: opts

  def call(conn, _opts) do
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    user_id = get_user_id(conn)

    with {:ok, true} <- check_rate("ip:#{ip}", @ip_limit),
         {:ok, true} <- check_rate("user:#{user_id}", @user_limit) do
      conn
    else
      {:error, :rate_limited} ->
        conn
        |> send_resp(429, "Rate limit exceeded")
        |> halt()
    end
  end

  defp check_rate(key, limit) do
    case Hammer.check_rate(key, @interval, limit) do
      {:allow, _count} -> {:ok, true}
      {:deny, _limit} -> {:error, :rate_limited}
    end
  end

  defp get_user_id(conn) do
    conn.assigns[:current_user_id] || "anon"
  end
end
