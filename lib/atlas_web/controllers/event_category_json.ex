defmodule AtlasWeb.EventCategoryJSON do
  alias Atlas.Events.EventCategory

  @doc """
  Renders a list of event_categories.
  """
  def index(%{event_categories: event_categories}) do
    %{event_categories: for(event_category <- event_categories, do: data(event_category))}
  end

  @doc """
  Renders a single event_category.
  """
  def show(%{event_category: event_category}) do
    %{event_category: data(event_category)}
  end

  def data(%EventCategory{} = event_category) do
    %{
      id: event_category.id,
      name: event_category.name,
      color: event_category.color,
      course:
        if Ecto.assoc_loaded?(event_category.course) and event_category.course do
          AtlasWeb.University.CourseJSON.data(event_category.course)
        else
          nil
        end
    }
  end
end
