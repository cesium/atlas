defmodule Atlas.Workers.ImportStudentsByCourses do
  @moduledoc """
  Worker to import students by course.
  """
  use Oban.Worker, queue: :imports

  alias Atlas.Importers.StudentsByCourses

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"file_path" => file_path}}) do
    StudentsByCourses.import_from_excel_file(file_path)
    :ok
  end
end
