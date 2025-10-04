defmodule MittelUsers.Users.Domain.User do
  alias MittelUsers.Shared.Types.UUID
  @enforce_keys [:id, :email, :username]
  defstruct [
    :id,
    :email,
    :username,
    :password_hash,
    :inserted_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: UUID.t(),
          email: String.t(),
          username: String.t(),
          password_hash: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
