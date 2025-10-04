defmodule MittelUsers.Users.Domain.UserService do
  alias MittelUsers.Shared.Types.UUID
  alias MittelUsers.Users.Domain.User
  alias MittelUsers.Sessions.Domain.UserSession

  @user_repo Application.compile_env!(:mittel_users, :user_repository)
  @session_repo Application.compile_env!(:mittel_users, :session_repository)

  @spec get_user(UUID.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(%UUID{} = id), do: @user_repo.find_by_id(id)

  @spec get_user_by_username(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by_username(username), do: @user_repo.find_by_username(username)

  @spec introspect(String.t()) :: {:ok, User.t()} | {:error, :expired} | {:error, :invalid_token}
  def introspect(token) do
    with {:ok, %UserSession{} = session} <- @session_repo.find_by_token(token),
         {:ok, %User{} = user} <- @user_repo.find_by_id(session.user_id) do
      if session_expired?(session), do: {:error, :expired}, else: {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end

  @spec exists?(UUID.t()) :: {:ok, boolean()} | {:error, term()}
  def exists?(id), do: @user_repo.exists_by_id(id)

  @spec update(UUID.t(), map()) :: {:ok, User.t()} | {:error, :not_found} | {:error, term()}
  def update(%UUID{} = id, params) do
    case @user_repo.find_by_id(id) do
      {:ok, %User{} = user} -> @user_repo.save(Map.merge(user, params))
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  @spec delete(UUID.t()) :: :ok | {:error, :not_found} | {:error, term()}
  def delete(%UUID{} = id), do: @user_repo.delete(id)

  @spec session_expired?(UserSession.t()) :: boolean()
  defp session_expired?(session) do
    DateTime.compare(session.expires_at, DateTime.utc_now()) == :lt
  end
end
