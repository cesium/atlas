defmodule Atlas.Repo.Seeds.Accounts do
  alias Atlas.Accounts

  @first_names File.read!("priv/fake/first_names.txt") |> String.split("\n", trim: true)
  @last_names File.read!("priv/fake/last_names.txt") |> String.split("\n", trim: true)

  def run do
    case Accounts.list_users() do
      [] ->
        seed_users()

      _ ->
        IO.puts("Users already exist, skipping seeding.")
    end
  end

  def seed_users(students \\ 100, professors \\ 15, admins \\ 15) do
    seed_students(students)
    seed_professors(professors)
    seed_admins(admins)
  end

  defp seed_students(count) do
    for i <- 1..count do
      first_name = Enum.random(@first_names)
      last_names = Enum.take_random(@last_names, 3) |> Enum.join(" ")
      full_name = "#{first_name} #{last_names}"
      student_number = random_student_number()
      email = "#{student_number |> String.downcase()}@alunos.uminho.pt"

      student = %{
        name: full_name,
        email: email,
        password: "password1234",
        type: :student
      }

      create_user(student, "student", i)
    end
  end

  defp seed_professors(count) do
    for i <- 1..count do
      first_name = Enum.random(@first_names)
      last_names = Enum.take_random(@last_names, 3) |> Enum.join(" ")
      full_name = "#{first_name} #{last_names}"
      email = "professor#{i}@atlas.pt"

      professor = %{
        name: full_name,
        email: email,
        password: "password1234",
        type: :professor
      }

      create_user(professor, "professor", i)
    end
  end

  defp seed_admins(count) do
    for i <- 1..count do
      first_name = Enum.random(@first_names)
      last_names = Enum.take_random(@last_names, 3) |> Enum.join(" ")
      full_name = "#{first_name} #{last_names}"
      email = "admin#{i}@atlas.pt"

      admin = %{
        name: full_name,
        email: email,
        password: "password1234",
        type: :admin
      }

      create_user(admin, "admin", i)
    end
  end

  defp random_student_number do
    digits = for _ <- 1..5, into: "", do: Integer.to_string(Enum.random(1..9))
    "A1#{digits}"
  end

  defp create_user(attrs, role, id) do
    case Accounts.register_user(attrs) do
      {:ok, user} ->
        Mix.shell().info("Created #{role} #{user.name} (#{attrs.email})")

      {:error, changeset} ->
        Mix.shell().error("Error creating #{role} #{id}: " <> Kernel.inspect(changeset.errors))
    end
  end
end

Atlas.Repo.Seeds.Accounts.run()
