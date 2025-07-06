defmodule Atlas.RateLimiter do
  use Hammer, backend: :ets
end
