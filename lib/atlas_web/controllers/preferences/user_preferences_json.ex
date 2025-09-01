defmodule AtlasWeb.UserPreferencesJSON do
  @moduledoc """
  JSON API for user preferences.
  """

  alias Atlas.Accounts.UserPreferences

  def show(%{preferences: preferences}) do
    %{preferences: data(preferences)}
  end

  defp data(%UserPreferences{} = preferences) do
    %{
      id: preferences.id,
      language: preferences.language
    }
  end
end
