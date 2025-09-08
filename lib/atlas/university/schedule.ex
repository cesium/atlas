defmodule Atlas.University.Schedule do
  use Atlas.Context

  alias Atlas.University.Degrees.Courses.Course
  alias Atlas.University.Degrees.Courses.Shifts.Shift
  alias Atlas.University.Student
  alias Atlas.Workers

  @shift_type_letters %{
    :theoretical => "T",
    :theoretical_practical => "TP",
    :practical_laboratory => "PL",
    :tutorial_guidance => "OT"
  }

  @shift_types Map.new(@shift_type_letters, fn {k, v} -> {v, k} end)

  def request_schedule_generation(opts \\ %{}) do
    build_schedule_request(opts)
    |> then(
      &Finch.build(
        :post,
        "http://localhost:8000/api/v1/solve",
        [{"Content-Type", "application/json"}],
        &1
      )
    )
    |> Finch.request(Atlas.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_result(request_id) do
    IO.inspect(request_id, label: "Fetching schedule result for request ID")

    Finch.build(:get, "http://localhost:8000/api/v1/solution/#{request_id}")
    |> Finch.request(Atlas.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        case Jason.decode!(body) do
          %{"schedules" => schedules} ->
            Atlas.University.delete_all_original_shift_enrollments()
            import_schedule_result(schedules)
            {:ok, %{status: :completed}}

          %{"status" => status} when status in ["Running"] ->
            {:ok, %{status: :running}}

          other ->
            {:error, %{status: 200, body: other}}
        end

      {:ok, %Finch.Response{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def import_schedule_result(schedules) do
    schedules
    |> Enum.each(fn {student_number, enrollments} ->
      student = Atlas.University.get_student_by_number!(student_number)

      case student do
        nil ->
          nil

        %Student{} = student ->
          enrollments
          |> Enum.each(fn %{
                            "course" => course,
                            "shift_type" => shift_type,
                            "shift_number" => shift_number
                          } ->
            fetched_course = Atlas.University.Degrees.Courses.get_course_by_code(course)

            shift =
              Atlas.University.Degrees.Courses.Shifts.get_shift_by_course_type_number(
                fetched_course.id,
                Map.get(@shift_types, shift_type),
                shift_number
              )

            Atlas.University.create_shift_enrollment(%{
              student_id: student.id,
              shift_id: shift.id,
              status: :active
            })
          end)
      end
    end)
  end

  def build_schedule_request(opts \\ %{}) do
    Jason.encode!(%{
      students: get_students_data(opts),
      courses: get_courses_data(opts)
    })
  end

  defp get_students_data(opts) do
    Student
    |> join(:inner, [s], c in assoc(s, :courses))
    |> where([s, c], is_nil(c.parent_course_id))
    |> join(:left, [s, c], shift_enrollment in assoc(s, :shift_enrollments),
      on: shift_enrollment.status in [:active, :inactive]
    )
    |> join(:left, [s, c, shift_enrollment], shift in assoc(shift_enrollment, :shift))
    |> join(:left, [s, c, shift_enrollment, shift], shift_course in assoc(shift, :course))
    |> where(
      [s, c, shift_enrollment, shift, shift_course],
      is_nil(shift_enrollment.id) or
        (shift_course.degree_id == c.degree_id and shift_course.semester == c.semester)
    )
    |> build_students_filter(opts)
    |> preload([s, c, shift_enrollment, shift, shift_course],
      courses: c,
      shift_enrollments: {shift_enrollment, shift: [:course]}
    )
    |> Repo.all()
    |> Enum.map(&format_student_for_api/1)
  end

  defp format_student_for_api(%Student{} = student) do
    %{
      number: student.number,
      enrollments: Enum.map(student.courses, & &1.code),
      schedule:
        Enum.map(student.shift_enrollments, fn se ->
          %{
            course: se.shift.course.code,
            shift_type: Map.get(@shift_type_letters, se.shift.type),
            shift_number: se.shift.number
          }
        end),
      year: student.degree_year
    }
  end

  defp get_courses_data(opts) do
    Course
    |> where([c], is_nil(c.parent_course_id))
    |> build_courses_filter(opts)
    |> join(:left, [c], s in assoc(c, :shifts))
    |> join(:left, [c, s], ts in assoc(s, :timeslots))
    |> preload([c, s, ts], shifts: {s, timeslots: ts})
    |> Repo.all()
    |> Enum.map(&format_course_for_api/1)
  end

  defp format_course_for_api(%Course{} = course) do
    %{
      id: course.code,
      year: course.year,
      shifts: Enum.map(course.shifts, &format_shifts_for_api/1)
    }
  end

  defp format_shifts_for_api(%Shift{} = shift) do
    %{
      type: Map.get(@shift_type_letters, shift.type),
      number: shift.number,
      timeslots:
        Enum.map(shift.timeslots, fn ts ->
          %{
            day: ts.weekday,
            start: String.slice(to_string(ts.start), 0..4),
            end: String.slice(to_string(ts.end), 0..4)
          }
        end),
      capacity: shift.capacity
    }
  end

  defp build_students_filter(query, opts) do
    opts
    |> Enum.reduce(query, fn
      {:degree_id, degree_id}, query_acc ->
        where(query_acc, [s, c, se, shift, shift_course], s.degree_id == ^degree_id)

      {:semester, semester}, query_acc ->
        where(query_acc, [s, c, se, shift, shift_course], c.semester == ^semester)

      _, query_acc ->
        query_acc
    end)
  end

  defp build_courses_filter(query, opts) do
    opts
    |> Enum.reduce(query, fn
      {:degree_id, degree_id}, query_acc ->
        where(query_acc, [c], c.degree_id == ^degree_id)

      {:semester, semester}, query_acc ->
        where(query_acc, [c], c.semester == ^semester)

      _, query_acc ->
        query_acc
    end)
  end

  def queue_generate_schedule(job_id, user) do
    IO.inspect(job_id, label: "Queuing schedule generation for job ID")

    Oban.insert(
      Workers.GenerateStudentsSchedule.new(%{"job_id" => job_id},
        meta: %{user_id: user.id, type: :generate_students_schedule}
      )
    )
  end
end
