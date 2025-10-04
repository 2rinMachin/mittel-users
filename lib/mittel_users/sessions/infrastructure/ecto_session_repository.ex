defmodule MittelUsers.Sessions.Infrastructure.EctoSessionRepository do
  import Ecto.Query, warn: false

  alias MittelUsers.Repo
  alias MittelUsers.Sessions.Domain.{UserSession, SessionRepository}
  alias MittelUsers.Sessions.Adapter.EctoSession
  alias MittelUsers.Shared.Types.UUID
  @behaviour SessionRepository

  @impl true
  @spec find_by_token(String.t()) :: {:ok, UserSession.t()} | {:error, :not_found}
  def find_by_token(token) do
    case Repo.get_by(EctoSession, token: token) do
      nil -> {:error, :not_found}
      ecto_session -> {:ok, to_domain(ecto_session)}
    end
  end

  @impl true
  @spec create(UUID.t(), DateTime.t()) :: {:ok, UserSession.t()} | {:error, any()}
  def create(%UUID{} = user_id, %DateTime{} = expires_at) do
    token = generate_token()

    changeset =
      EctoSession.changeset(%EctoSession{}, %{
        user_id: user_id.value,
        token: token,
        expires_at: expires_at
      })

    case Repo.insert(changeset) do
      {:ok, ecto_session} -> {:ok, to_domain(ecto_session)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  @spec delete(String.t()) :: :ok | {:error, any()}
  def delete(token) do
    case Repo.get_by(Session, token: token) do
      nil ->
        {:error, :not_found}

      ecto_session ->
        case Repo.delete(ecto_session) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @impl true
  @spec delete_all_for_user(UUID.t()) :: :ok | {:error, any()}
  def delete_all_for_user(%UUID{value: value}) do
    from(s in EctoSession, where: s.user_id == ^value)
    |> Repo.delete_all()
  end

  defp generate_token() do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end

  defp to_domain(%EctoSession{} = ecto_session) do
    %UserSession{
      id: ecto_session.id,
      user_id: ecto_session.user_id,
      token: ecto_session.token,
      expires_at: ecto_session.expires_at,
      inserted_at: ecto_session.inserted_at
    }
  end

  # defp from_domain(%UserSession{} = domain_session) do
  #   %EctoSession{
  #     id: domain_session.id,
  #     user_id: domain_session.user_id,
  #     token: domain_session.token,
  #     expires_at: domain_session.expires_at,
  #     inserted_at: domain_session.inserted_at
  #   }
  # end
end
