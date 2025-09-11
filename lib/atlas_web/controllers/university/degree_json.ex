defmodule AtlasWeb.University.DegreeJSON do
  alias Atlas.University.Degrees.Degree

  def index(%{degrees: degrees}) do
    %{degrees: for(degree <- degrees, do: data(degree))}
  end

  def data(%Degree{} = degree) do
    %{
      id: degree.id,
      code: degree.code,
      name: degree.name
    }
  end
end
