defmodule MittelAuth.Sessions.Domain.SessionRepository do
  alias MittelAuth.Sessions.Domain.Session

  @callback find_by_token(token :: String.t()) :: {:ok, Session.t()} | {:error, :not_found}
  @callback create(user_id :: Ecto.UUID.t(), expires_at :: DateTime.t()) ::
              {:ok, Session.t()} | {:error, any()}
  @callback delete(token :: String.t()) :: :ok | {:error, any()}
  @callback delete_all_for_user(user_id :: Ecto.UUID.t()) :: :ok | {:error, any()}
end
