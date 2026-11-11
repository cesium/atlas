defmodule Atlas.Repo.Seeds.Feedbacks do
  alias Atlas.Accounts.User
  alias Atlas.Feedbacks.Feedback
  alias Atlas.Repo

  import Ecto.Query

  @reports [
    {"Shift disappeared", "One of my shifts is no longer showing on my schedule."},
    {"Exchange stuck", "My exchange request has been pending for a week and nothing happens."},
    {"Wrong room", "The schedule says the class is in CP1 but it was moved to CP2."},
    {"Calendar not loading", "The calendar page keeps loading forever on my phone."},
    {"Export broken", "Exporting my schedule to Google Calendar creates duplicated events."},
    {"Login issue", "I get logged out every time I close the browser."},
    {"Typo in course name", "There is a typo in one of the course names on the schedule page."},
    {"Dark mode", "Would be great to have a dark mode, the white background hurts at night."},
    {"Events missing",
     "The events calendar is missing the talks from this week. I checked the CeSIUM page and " <>
       "there are at least three events that should be there, including the one on Thursday " <>
       "afternoon. Some of my friends also noticed the same thing, so it does not seem to be " <>
       "only on my account. It would be nice if the events were synced more often, or if there " <>
       "was a way to tell when the last sync happened."},
    {"Overlapping classes",
     "After the last exchange my schedule shows two classes at the same time on Monday " <>
       "morning. I am not sure if the exchange was applied twice or if the old shift was not " <>
       "removed. I tried refreshing and signing out, but it still shows both. Could someone " <>
       "check what happened with my shifts?"}
  ]

  def run do
    case Repo.aggregate(Feedback, :count) do
      0 -> seed_feedbacks()
      _ -> IO.puts("Feedbacks already exist, skipping seeding.")
    end
  end

  def seed_feedbacks(count \\ 45) do
    case Repo.all(from u in User, where: u.type in [:student, :professor], select: u.id) do
      [] ->
        Mix.shell().error("No users found. Please run the users seed first.")

      user_ids ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        for _ <- 1..count do
          {subject, message} = Enum.random(@reports)
          inserted_at = DateTime.add(now, -Enum.random(0..(60 * 24 * 60 * 60)), :second)

          Repo.insert!(%Feedback{
            subject: subject,
            message: message,
            user_id: Enum.random(user_ids),
            inserted_at: inserted_at,
            updated_at: inserted_at
          })
        end
    end
  end
end

Atlas.Repo.Seeds.Feedbacks.run()
