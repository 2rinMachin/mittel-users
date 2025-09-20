defmodule MittelAuth.Users.Domain.UserRepository do
  alias MittelAuth.Users.Domain.User

  @callback find_by_id(id :: Ecto.UUID.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback find_by_email(email :: String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback exists_by_id(id :: Ecto.UUID.t()) :: {:ok, boolean()} | {:error, any()}
  @callback save(changeset :: Ecto.Changeset.t()) :: {:ok, User.t()} | {:error, any()}
  @callback delete(user :: User.t()) :: :ok | {:error, any()}
  @callback delete(id :: Ecto.UUID.t()) :: :ok | {:error, any()}
end
