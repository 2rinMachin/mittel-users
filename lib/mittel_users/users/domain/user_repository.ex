defmodule MittelUsers.Users.Domain.UserRepository do
  alias MittelUsers.Users.Domain.User
  alias MittelUsers.Shared.Types.UUID

  @callback find_by_id(id :: UUID.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback find_by_email(email :: String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback find_by_username(username :: String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback find_by_username_like(partial :: String.t()) :: [User.t()]
  @callback exists_by_id(id :: UUID.t()) :: {:ok, boolean()} | {:error, term()}
  @callback update_role(id :: UUID.t(), User.role()) :: {:ok, User.t()} | {:error, :not_found}
  @callback save(user :: User.t()) :: {:ok, User.t()} | {:error, term()}
  @callback delete(id :: UUID.t()) :: :ok | {:error, term()}
  @callback delete(user :: User.t()) :: :ok | {:error, term()}
end
