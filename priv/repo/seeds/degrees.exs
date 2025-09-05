defmodule Atlas.Repo.Seeds.Degrees do
  alias Atlas.University.Degrees

  @degrees [
    %{name: "Licenciatura em Engenharia Informática", code: "J3"},
    %{name: "Mestrado em Engenharia Informática", code: "M002"}
  ]

  def run do
    case Degrees.list_degrees() do
      [] ->
        seed_degrees()

      _ ->
        IO.puts("Degrees already exist, skipping seeding.")
    end
  end

  def seed_degrees do
    for degree <- @degrees do
      case Degrees.create_degree(degree) do
        {:ok, _degree} ->
          IO.puts("Created degree #{degree.name} (#{degree.code})")

        {:error, changeset} ->
          IO.puts("Error creating degree #{degree.name}: " <> Kernel.inspect(changeset.errors))
      end
    end
  end
end

Atlas.Repo.Seeds.Degrees.run()
