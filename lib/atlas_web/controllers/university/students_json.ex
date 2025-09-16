defmodule AtlasWeb.University.StudentsJSON do
  alias Atlas.Accounts.User
  alias AtlasWeb.MetaJSON

  def index(%{students: students, meta: meta}) do
    %{
      users: for(student <- students, do: data(student)),
      meta: MetaJSON.data(meta)
    }
  end

  def data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      student: %{
        id: user.student.id,
        number: user.student.number,
        special_status: user.student.special_status,
        degree_year: user.student.degree_year
      }
    }
  end
end
