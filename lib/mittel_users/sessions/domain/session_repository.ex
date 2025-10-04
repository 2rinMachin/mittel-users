defmodule MittelUsers.Sessions.Domain.SessionRepository do
  alias MittelUsers.Sessions.Domain.UserSession
  alias MittelUsers.Shared.Types.UUID

  @callback find_by_token(token :: String.t()) :: {:ok, UserSession.t()} | {:error, :not_found}
  @callback create(user_id :: UUID.t(), expires_at :: DateTime.t()) ::
              {:ok, UserSession.t()} | {:error, any()}
  @callback delete(token :: String.t()) :: :ok | {:error, any()}
  @callback delete_all_for_user(user_id :: UUID.t()) :: :ok | {:error, any()}
end
