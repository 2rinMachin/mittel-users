defmodule MittelUsers.Auth.Domain.AuthService do
  alias MittelUsers.Sessions.Domain.UserSession
  alias MittelUsers.Users.Domain.User
  alias MittelUsers.Shared.Types.UUID

  @user_repo Application.compile_env!(:mittel_users, :user_repository)
  @session_repo Application.compile_env!(:mittel_users, :session_repository)

  @spec register(%{
          required(:email) => String.t(),
          required(:username) => String.t(),
          required(:password) => String.t()
        }) :: {:ok, User.t()} | {:error, term()}
  def register(attrs) do
    with {:ok, hash} <- hash_password(attrs.password),
         uuid <- UUID.generate() do
      user = %User{
        id: uuid,
        email: attrs.email,
        username: attrs.username,
        password_hash: hash,
        role: :user
      }

      @user_repo.save(user)
    end
  end

  @spec authenticate(String.t(), String.t()) :: {:ok, User.t()} | {:error, :invalid_credentials}
  def authenticate(email, password) do
    with {:ok, user} <- @user_repo.find_by_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      _ -> {:error, :invalid_credentials}
    end
  end

  @spec create_session(User.t(), pos_integer()) :: {:ok, UserSession.t()} | {:error, term()}
  def create_session(%User{} = user, ttl_seconds \\ 60 * 60 * 24) do
    expires_at = DateTime.add(DateTime.utc_now(), ttl_seconds, :second)
    @session_repo.create(user.id, expires_at)
  end

  @spec validate(String.t()) :: boolean()
  def validate(token) do
    case @session_repo.find_by_token(token) do
      {:ok, session} -> not expired?(session)
      {:error, :not_found} -> false
    end
  end

  @spec logout(String.t()) :: :ok | {:error, term()}
  def logout(token), do: @session_repo.delete(token)

  @spec expired?(UserSession.t()) :: boolean()
  defp expired?(%UserSession{} = session) do
    DateTime.compare(session.expires_at, DateTime.utc_now()) == :lt
  end

  @spec hash_password(String.t()) :: {:ok, String.t()}
  defp hash_password(password) when is_binary(password) do
    {:ok, Bcrypt.hash_pwd_salt(password)}
  end
end
