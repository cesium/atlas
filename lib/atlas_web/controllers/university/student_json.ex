defmodule AtlasWeb.University.StudentJSON do
  alias Atlas.University.Student
  alias AtlasWeb.MetaJSON

  def index(%{students: students, meta: meta}) do
    %{
      users: for(student <- students, do: data(student)),
      meta: MetaJSON.data(meta)
    }
  end

  def show(%{student: student}) do
    %{student: data(student)}
  end

  def data(%Student{} = student) do
    %{
      id: student.id,
      number: student.number,
      special_status: student.special_status,
      degree_year: student.degree_year,
      user:
        if Ecto.assoc_loaded?(student.user) && student.user do
          AtlasWeb.UserJSON.data(student.user)
        else
          nil
        end
    }
  end
end
