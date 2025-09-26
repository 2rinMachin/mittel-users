defmodule MittelUsers.Sessions.Infrastructure.EctoSessionRepository do
  import Ecto.Query, only: [from: 2]

  alias MittelUsers.Repo
  alias MittelUsers.Sessions.Domain.{Session, SessionRepository}
  @behaviour SessionRepository

  @impl true
  def find_by_token(token) do
    case Repo.get_by(Session, token: token) do
      nil -> {:error, :not_found}
      session -> {:ok, session}
    end
  end

  @impl true
  def create(user_id, expires_at) do
    token = generate_token()

    %Session{}
    |> Session.changeset(%{user_id: user_id, token: token, expires_at: expires_at})
    |> Repo.insert()
  end

  @impl true
  def delete(token) do
    case Repo.get_by(Session, token: token) do
      nil -> {:error, :not_found}
      session -> Repo.delete(session) && :ok
    end
  end

  @impl true
  def delete_all_for_user(user_id) do
    from(s in Session, where: s.user_id == ^user_id)
    |> Repo.delete_all()
  end

  defp generate_token() do
    :crypto.strong_rand_bytes(32)
    |> Base.url_encode64(padding: false)
  end
end
