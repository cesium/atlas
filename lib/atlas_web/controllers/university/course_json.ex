defmodule AtlasWeb.University.CourseJSON do
  alias Atlas.University.Degrees.Courses.Course
  alias AtlasWeb.University.CourseJSON
  alias AtlasWeb.ShiftsJSON

  def index(%{courses: courses}) do
    %{courses: for(course <- courses, do: data(course))}
  end

  def data(%Course{} = course) do
    %{
      id: course.id,
      name: course.name,
      shortname: course.shortname,
      code: course.code,
      year: course.year,
      semester: course.semester,
      courses:
        if Ecto.assoc_loaded?(course.courses) do
          for(subcourse <- course.courses, do: CourseJSON.data(subcourse))
        else
          []
        end,
      shifts:
        if Ecto.assoc_loaded?(course.shifts) do
          for(shift <- course.shifts, do: ShiftsJSON.data(shift))
        else
          []
        end
    }
  end
end
