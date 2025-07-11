defmodule Atlas.Repo.Seeds.Accounts do
  alias Atlas.Accounts

  @first_names File.read!("priv/fake/first_names.txt") |> String.split("\n")
  @last_names File.read!("priv/fake/last_names.txt") |> String.split("\n")

  def run do
    case Accounts.list_users() do
      [] ->
        seed_users()

      _ ->
        IO.puts("Users already exist, skipping seeding.")
    end
  end

  def seed_users(students \\ 100, _teachers \\ 3, _admins \\ 3) do
    # Students
    for _ <- 1..students do
      first_name = Enum.random(@first_names)
      last_name = Enum.random(@last_names)
      student_number = random_student_number()
      email = "#{student_number |> String.downcase()}@alunos.uminho.pt"

      student = %{
        name: "#{first_name} #{last_name}",
        email: email,
        password: "password1234",
        type: :student
      }

      case Accounts.register_user(student) do
        {:ok, user} ->
          Mix.shell().info("Created student #{user.name} (#{student_number})")
        {:error, changeset} ->
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end

  defp random_student_number do
    digits = for _ <- 1..5, into: "", do: Integer.to_string(Enum.random(1..9))
    "A1#{digits}"
  end
end

Atlas.Repo.Seeds.Accounts.run()
