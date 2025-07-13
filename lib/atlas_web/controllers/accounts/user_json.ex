defmodule AtlasWeb.UserJSON do
  @moduledoc """
  A module for rendering user data in JSON format.
  """

  alias Atlas.Accounts.User

  @doc """
  Renders a list of users as JSON.
  """
  def index(%{users: users}) do
    %{users: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user as JSON.
  """
  def show(%{user: %User{} = user}) do
    %{user: data(user)}
  end

  @doc """
  Renders a user as JSON.
  """
  def data(user) do
    %{
      id: user.id,
      email: user.email,
      name: user.name,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
