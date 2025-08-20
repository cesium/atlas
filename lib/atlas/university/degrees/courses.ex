defmodule Atlas.University.Degrees.Courses do
  @moduledoc """
  The Courses context.
  """
  use Atlas.Context

  alias Atlas.University.Degrees.Courses.Course

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Gets a single course by code.

  ## Examples

      iex> get_course_by_code("J301N1")
      %Course{}

      iex> get_course_by_code("NONEXISTENT")
      nil
  """
  def get_course_by_code(code) do
    Repo.get_by(Course, code: code)
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  @doc """
  Gets the semester from the course code.

  ## Examples

      iex> get_semester_from_code("J301N1")
      1

      iex> get_semester_from_code("J302N1")
      2

  """
  def get_semester_from_code(code) do
    case String.at(code, 3) |> Integer.parse() do
      {n, _} -> if rem(n, 2) == 0, do: 2, else: 1
      _ -> 1
    end
  end

  @doc """
  Gets the year from the course code.

  ## Examples

      iex> get_year_from_code("J302N1")
      1

      iex> get_year_from_code("J303N1")
      2

  """
  def get_year_from_code(code) do
    case String.at(code, 3) |> Integer.parse() do
      {n, _} -> ceil(n / 2.0)
      _ -> 1
    end
  end
end
