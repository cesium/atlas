defmodule Atlas.Uploaders.UserAvatar do
  @moduledoc """
  User Avatar image uploader.
  """
  use Atlas.Uploader

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(extension_whitelist(), file_extension) do
      true -> :ok
      false -> {:error, "Invalid file type"}
    end
  end

  def storage_dir(_version, {_file, %{id: user_id}}) do
    "uploads/user/avatars/#{user_id}"
  end

  def filename(version, _) do
    version
  end

  def extension_whitelist do
    @extension_whitelist
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end
end
