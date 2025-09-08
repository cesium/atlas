defmodule Atlas.University do
  @moduledoc """
  The University context.
  """

  use Atlas.Context

  alias Atlas.University.{CourseEnrollment, Student}
  alias Atlas.University.Degrees.Courses.Course
  alias Atlas.Workers

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students do
    Repo.all(Student)
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id), do: Repo.get!(Student, id)

  @doc """
  Gets a single student by number.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student_by_number!(12345)
      %Student{}

      iex> get_student_by_number!(67890)
      ** (Ecto.NoResultsError)

  """
  def get_student_by_number!(number) do
    Repo.get_by!(Student, number: number)
  end

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.changeset(student, attrs)
  end

  @doc """
  Returns the list of course enrollments.

  ## Examples

      iex> list_course_enrollments()
      [%CourseEnrollment{}, ...]

  """
  def list_course_enrollments do
    Repo.all(CourseEnrollment)
  end

  @doc """
  Gets a single course enrollment.

  Raises `Ecto.NoResultsError` if the CourseEnrollment does not exist.

  ## Examples

      iex> get_course_enrollment!(123)
      %CourseEnrollment{}

      iex> get_course_enrollment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course_enrollment!(id), do: Repo.get!(CourseEnrollment, id)

  @doc """
  Creates a course enrollment.

  ## Examples

      iex> create_course_enrollment(%{field: value})
      {:ok, %CourseEnrollment{}}

      iex> create_course_enrollment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course_enrollment(attrs \\ %{}) do
    %CourseEnrollment{}
    |> CourseEnrollment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course enrollment.

  ## Examples

      iex> update_course_enrollment(course_enrollment, %{field: new_value})
      {:ok, %CourseEnrollment{}}

      iex> update_course_enrollment(course_enrollment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course_enrollment(%CourseEnrollment{} = course_enrollment, attrs) do
    course_enrollment
    |> CourseEnrollment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course enrollment.

  ## Examples

      iex> delete_course_enrollment(course_enrollment)
      {:ok, %CourseEnrollment{}}

      iex> delete_course_enrollment(course_enrollment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course_enrollment(%CourseEnrollment{} = course_enrollment) do
    Repo.delete(course_enrollment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course_enrollment changes.

  ## Examples

      iex> change_course_enrollment(course_enrollment)
      %Ecto.Changeset{data: %CourseEnrollment{}}

  """
  def change_course_enrollment(%CourseEnrollment{} = course_enrollment, attrs \\ %{}) do
    CourseEnrollment.changeset(course_enrollment, attrs)
  end

  @doc """
  Enrolls a student in a course.

  ## Examples

      iex> enroll_student_in_course(student, course)
      {:ok, %CourseEnrollment{}}

      iex> enroll_student_in_course(student, course)
      {:error, %Ecto.Changeset{}}
  """
  def enroll_student_in_course(student, course) do
    %CourseEnrollment{}
    |> CourseEnrollment.changeset(%{student_id: student.id, course_id: course.id})
    |> Repo.insert()
  end

  @doc """
  Queues a job to import students by courses from an Excel file.

  ## Examples

      iex> queue_import_students_by_courses(file_path, user)
      {:ok, %Oban.Job{}}

      iex> queue_import_students_by_courses(file_path, user)
      {:error, reason}
  """
  def queue_import_students_by_courses(file_path, user) do
    Oban.insert(
      Workers.ImportStudentsByCourses.new(%{"file_path" => file_path},
        meta: %{user_id: user.id, type: :import_students_by_courses}
      )
    )
  end

  @doc """
  Queues a job to import shifts by courses from a CSV file.

  ## Examples

      iex> queue_import_shifts_by_courses(file_path, user)
      {:ok, %Oban.Job{}}

      iex> queue_import_shifts_by_courses(file_path, user)
      {:error, reason}
  """
  def queue_import_shifts_by_courses(file_path, user) do
    Oban.insert(
      Workers.ImportShiftsByCourses.new(%{"file_path" => file_path},
        meta: %{user_id: user.id, type: :import_shifts_by_courses}
      )
    )
  end

  alias Atlas.University.ShiftEnrollment

  @doc """
  Returns the list of shift_enrollments.

  ## Examples

      iex> list_shift_enrollments()
      [%ShiftEnrollment{}, ...]

  """
  def list_shift_enrollments do
    Repo.all(ShiftEnrollment)
  end

  @doc """
  Gets a single shift_enrollment.

  Raises `Ecto.NoResultsError` if the Shift enrollment does not exist.

  ## Examples

      iex> get_shift_enrollment!(123)
      %ShiftEnrollment{}

      iex> get_shift_enrollment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift_enrollment!(id), do: Repo.get!(ShiftEnrollment, id)

  @doc """
  Creates a shift_enrollment.

  ## Examples

      iex> create_shift_enrollment(%{field: value})
      {:ok, %ShiftEnrollment{}}

      iex> create_shift_enrollment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_enrollment(attrs \\ %{}) do
    %ShiftEnrollment{}
    |> ShiftEnrollment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift_enrollment.

  ## Examples

      iex> update_shift_enrollment(shift_enrollment, %{field: new_value})
      {:ok, %ShiftEnrollment{}}

      iex> update_shift_enrollment(shift_enrollment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift_enrollment(%ShiftEnrollment{} = shift_enrollment, attrs) do
    shift_enrollment
    |> ShiftEnrollment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift_enrollment.

  ## Examples

      iex> delete_shift_enrollment(shift_enrollment)
      {:ok, %ShiftEnrollment{}}

      iex> delete_shift_enrollment(shift_enrollment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift_enrollment(%ShiftEnrollment{} = shift_enrollment) do
    Repo.delete(shift_enrollment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift_enrollment changes.

  ## Examples

      iex> change_shift_enrollment(shift_enrollment)
      %Ecto.Changeset{data: %ShiftEnrollment{}}

  """
  def change_shift_enrollment(%ShiftEnrollment{} = shift_enrollment, attrs \\ %{}) do
    ShiftEnrollment.changeset(shift_enrollment, attrs)
  end

  def delete_all_original_shift_enrollments() do
    ShiftEnrollment
    |> where([se], se.status in [:active, :inactive])
    |> Repo.delete_all()
  end

  @doc """
  Lists the schedule for a student.

  ## Examples

      iex> list_student_schedule(123)
      [%Course{}, ...]

  """
  def list_student_schedule(student_id, original_only \\ false) do
    statuses = if original_only, do: [:active, :inactive], else: [:active, :override]

    Course
    |> join(:left, [c], cc in assoc(c, :courses))
    |> join(:left, [c], s in assoc(c, :shifts))
    |> join(:left, [c, cc], cs in assoc(cc, :shifts))
    |> join(:inner, [c, cc, s, cs], se in Atlas.University.ShiftEnrollment,
      on: se.shift_id == s.id or se.shift_id == cs.id
    )
    |> join(:left, [c, cc, s], t1 in assoc(s, :timeslots))
    |> join(:left, [c, cc, s, cs], t2 in assoc(cs, :timeslots))
    |> where([c], is_nil(c.parent_course_id))
    |> where([c, cc, s, cs, se], se.student_id == ^student_id)
    |> where([c, cc, s, cs, se], se.status in ^statuses)
    |> preload([c, cc, s, cs, se, t1, t2],
      shifts: {s, timeslots: t1},
      courses: {cc, shifts: {cs, timeslots: t2}}
    )
    |> Repo.all()
  end

  @doc """
  Updates the schedule for a student.

  ## Examples

      iex> update_student_schedule(123, [123, 345])
      {:ok, [%Course{}]}

      iex> update_student_schedule(123, [456])
      {:error, %Ecto.Changeset{}}

  """
  def update_student_schedule(student_id, shifts, override_original \\ false) do
    if override_original do
      update_student_schedule_with_override(student_id, shifts)
    else
      update_student_schedule_normal(student_id, shifts)
    end
  end

  defp update_student_schedule_with_override(student_id, shifts) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_all_existing_enrollments,
      ShiftEnrollment
      |> where([se], se.student_id == ^student_id)
    )
    |> Ecto.Multi.run(:insert_new_schedule, fn repo, _changes ->
      insert_new_shift_enrollments(repo, student_id, shifts, :active)
    end)
    |> Repo.transact()
  end

  defp update_student_schedule_normal(student_id, shifts) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(
      :delete_existing_enrollment_overrides,
      ShiftEnrollment
      |> where(
        [se],
        se.student_id == ^student_id and se.status == :override and se.shift_id not in ^shifts
      )
    )
    |> Ecto.Multi.update_all(
      :deactivate_removed_enrollments,
      ShiftEnrollment
      |> where(
        [se],
        se.student_id == ^student_id and se.status == :active and se.shift_id not in ^shifts
      ),
      set: [status: :inactive]
    )
    |> Ecto.Multi.update_all(
      :reactivate_existing_enrollments,
      ShiftEnrollment
      |> where(
        [se],
        se.student_id == ^student_id and se.status == :inactive and se.shift_id in ^shifts
      ),
      set: [status: :active]
    )
    |> Ecto.Multi.run(:insert_new_schedule, fn repo, _changes ->
      existing_shift_ids = fetch_existing_shifts(repo, student_id, shifts)
      new_shift_ids = shifts |> Enum.filter(&(!MapSet.member?(existing_shift_ids, &1)))
      insert_new_shift_enrollments(repo, student_id, new_shift_ids)
    end)
    |> Repo.transact()
  end

  defp fetch_existing_shifts(repo, student_id, shifts) do
    repo.all(
      ShiftEnrollment
      |> where(
        [se],
        se.student_id == ^student_id and se.shift_id in ^shifts
      )
      |> select([se], se.shift_id)
    )
    |> MapSet.new()
  end

  defp insert_new_shift_enrollments(repo, student_id, new_shift_ids, status \\ :override) do
    new_shift_ids
    |> Enum.reduce_while({:ok, []}, fn shift_id, {:ok, acc} ->
      shift_id
      |> create_shift_enrollment_changeset(student_id, status)
      |> repo.insert()
      |> case do
        {:ok, enrollment} -> {:cont, {:ok, [enrollment | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, results} -> {:ok, results}
      error -> error
    end
  end

  defp create_shift_enrollment_changeset(shift_id, student_id, status) do
    %ShiftEnrollment{}
    |> ShiftEnrollment.changeset(%{
      student_id: student_id,
      shift_id: shift_id,
      status: status
    })
  end
end
