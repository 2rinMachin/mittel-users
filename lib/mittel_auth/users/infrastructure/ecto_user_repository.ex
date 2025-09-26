defmodule MittelUsers.Users.Infrastructure.EctoUserRepository do
  import Ecto.Query, warn: false

  alias MittelUsers.Repo
  alias MittelUsers.Users.Domain.{User, UserRepository}
  @behaviour UserRepository

  @impl true
  def find_by_id(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @impl true
  def find_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @impl true
  def exists_by_id(id) do
    query = from u in User, where: u.id == ^id, select: 1

    case Repo.one(query) do
      nil -> {:ok, false}
      _ -> {:ok, true}
    end
  rescue
    e -> {:error, e}
  end

  @impl true
  def save(changeset) do
    case Repo.insert_or_update(changeset) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def delete(%User{} = user) do
    case Repo.delete(user) do
      {:ok, _struct} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def delete(id) do
    case find_by_id(id) do
      {:ok, user} -> delete(user)
      {:error, :not_found} -> {:error, :not_found}
    end
  end
end
