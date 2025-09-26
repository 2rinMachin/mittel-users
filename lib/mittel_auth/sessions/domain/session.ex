defmodule MittelUsers.Sessions.Domain.Session do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sessions" do
    field :user_id, :binary_id
    field :token, :string
    field :expires_at, :naive_datetime

    timestamps(updated_at: false, type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          token: String.t(),
          inserted_at: DateTime.t(),
          expires_at: DateTime.t()
        }

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token, :expires_at])
    |> validate_required([:user_id, :token, :expires_at])
    |> unique_constraint(:token)
  end
end
