defmodule MittelUsers.Users.Adapter.EctoUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias MittelUsers.Shared.Types.EctoUUID

  @primary_key {:id, EctoUUID, autogenerate: true}
  schema "users" do
    field :email, :string
    field :username, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          email: String.t(),
          username: String.t(),
          password_hash: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([:email, :username])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
