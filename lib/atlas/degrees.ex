defmodule Atlas.Degrees do
  @moduledoc """
  The Degrees context.
  """
  use Atlas.Context

  alias Atlas.Degrees.{Course, Degree}

  @doc """
  Returns the list of degrees.

  ## Examples

      iex> list_degrees()
      [%Degree{}, ...]

  """
  def list_degrees do
    Repo.all(Degree)
  end

  @doc """
  Gets a single degree.

  Raises `Ecto.NoResultsError` if the Degree does not exist.

  ## Examples

      iex> get_degree!(123)
      %Degree{}

      iex> get_degree!(456)
      ** (Ecto.NoResultsError)

  """
  def get_degree!(id), do: Repo.get!(Degree, id)

  @doc """
  Gets a single degree by code.

  ## Examples

      iex> get_degree_by_code("CS101")
      %Degree{}

      iex> get_degree_by_code("NONEXISTENT")
      nil

  """
  def get_degree_by_code(code) do
    Repo.get_by(Degree, code: code)
  end

  @doc """
  Creates a degree.

  ## Examples

      iex> create_degree(%{field: value})
      {:ok, %Degree{}}

      iex> create_degree(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_degree(attrs \\ %{}) do
    %Degree{}
    |> Degree.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a degree.

  ## Examples

      iex> update_degree(degree, %{field: new_value})
      {:ok, %Degree{}}

      iex> update_degree(degree, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_degree(%Degree{} = degree, attrs) do
    degree
    |> Degree.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a degree.

  ## Examples

      iex> delete_degree(degree)
      {:ok, %Degree{}}

      iex> delete_degree(degree)
      {:error, %Ecto.Changeset{}}

  """
  def delete_degree(%Degree{} = degree) do
    Repo.delete(degree)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking degree changes.

  ## Examples

      iex> change_degree(degree)
      %Ecto.Changeset{data: %Degree{}}

  """
  def change_degree(%Degree{} = degree, attrs \\ %{}) do
    Degree.changeset(degree, attrs)
  end

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
end
