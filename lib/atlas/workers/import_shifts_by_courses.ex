defmodule Atlas.Workers.ImportShiftsByCourses do
  @moduledoc """
  Worker to import shifts by course.
  """
  use Oban.Worker, queue: :imports

  alias Atlas.Importers.ShiftsByCourses

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"file_path" => file_path}}) do
    ShiftsByCourses.import_from_csv_file(file_path)
    :ok
  end
end
