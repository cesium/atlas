defmodule Atlas.Workers.ImportStudentsByCourse do
  @moduledoc """
  Worker to import students by course.
  """
  use Oban.Worker, queue: :imports

  alias Atlas.Importers.StudentsByCourse

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"file_path" => file_path}}) do
    StudentsByCourse.import_from_excel_file(file_path)
    :ok
  end
end
