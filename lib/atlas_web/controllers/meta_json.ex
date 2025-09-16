defmodule AtlasWeb.MetaJSON do
  @moduledoc """
  A module for rendering meta information in JSON format.
  """

  alias Flop.Meta

  def data(%Meta{} = meta) do
    %{
      current_page: meta.current_page || 1,
      page_size: meta.page_size || 20,
      total_pages: meta.total_pages || 0,
      total_entries: meta.total_count || 0,
      has_next_page: meta.has_next_page? || false,
      has_previous_page: meta.has_previous_page? || false,
      next_page: meta.next_page,
      previous_page: meta.previous_page,
      sort: format_sort(meta.flop.order_by),
      filters: format_filters(meta.flop.filters)
    }
  end

  defp format_sort(nil), do: []
  defp format_sort(order_by) when is_list(order_by), do: order_by
  defp format_sort(order_by), do: [order_by]

  defp format_filters(nil), do: []

  defp format_filters(filters) when is_list(filters) do
    Enum.map(filters, fn %Flop.Filter{field: f, op: o, value: v} ->
      %{field: f, op: o, value: v}
    end)
  end

  defp format_filters(_), do: []
end
