defmodule MittelUsers.Users.Infrastructure.EctoUserRepository do
  import Ecto.Query, warn: false

  alias MittelUsers.Repo
  alias MittelUsers.Users.Domain.User
  alias MittelUsers.Users.Domain.UserRepository
  alias MittelUsers.Users.Adapter.EctoUser
  alias MittelUsers.Shared.Types.UUID
  @behaviour UserRepository

  @impl true
  @spec find_by_id(UUID.t()) :: {:ok, User.t()} | {:error, :not_found}
  def find_by_id(%UUID{} = id) do
    case Repo.get(EctoUser, id.value) do
      nil -> {:error, :not_found}
      ecto_user -> {:ok, to_domain(ecto_user)}
    end
  end

  @impl true
  @spec find_by_email(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def find_by_email(email) do
    case Repo.get_by(EctoUser, email: email) do
      nil -> {:error, :not_found}
      ecto_user -> {:ok, to_domain(ecto_user)}
    end
  end

  @impl true
  @spec find_by_username(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def find_by_username(username) do
    case Repo.get_by(EctoUser, username: username) do
      nil -> {:error, :not_found}
      ecto_user -> {:ok, to_domain(ecto_user)}
    end
  end

  @impl true
  @spec exists_by_id(UUID.t()) :: {:ok, boolean()} | {:error, term()}
  def exists_by_id(%UUID{value: value}) do
    query = from u in EctoUser, where: u.id == ^value, select: 1

    case Repo.one(query) do
      nil -> {:ok, false}
      _ -> {:ok, true}
    end
  rescue
    unexpected -> {:error, unexpected}
  end

  @impl true
  @spec save(User.t()) :: {:ok, User.t()} | {:error, term()}
  def save(%User{} = domain_user) do
    ecto_user = from_domain(domain_user)

    changeset =
      EctoUser.changeset(ecto_user, %{
        email: domain_user.email,
        username: domain_user.username,
        password_hash: domain_user.password_hash
      })

    case Repo.insert_or_update(changeset) do
      {:ok, ecto_user} -> {:ok, to_domain(ecto_user)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  @spec delete(UUID.t()) :: :ok | {:error, term()}
  def delete(%UUID{} = id) do
    case Repo.get(EctoUser, id.value) do
      nil ->
        {:error, :not_found}

      ecto_user ->
        case Repo.delete(ecto_user) do
          {:ok, _} -> :ok
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @impl true
  @spec delete(User.t()) :: :ok | {:error, term()}
  def delete(%User{} = user) do
    delete(user.id)
  end

  @spec to_domain(EctoUser.t()) :: User.t()
  defp to_domain(%EctoUser{} = ecto_user) do
    %User{
      id: ecto_user.id,
      email: ecto_user.email,
      username: ecto_user.username,
      password_hash: ecto_user.password_hash,
      inserted_at: ecto_user.inserted_at,
      updated_at: ecto_user.updated_at
    }
  end

  @spec from_domain(User.t()) :: EctoUser.t()
  defp from_domain(%User{} = domain_user) do
    %EctoUser{
      id: domain_user.id,
      email: domain_user.email,
      username: domain_user.username,
      password_hash: domain_user.password_hash,
      inserted_at: domain_user.inserted_at,
      updated_at: domain_user.updated_at
    }
  end
end
