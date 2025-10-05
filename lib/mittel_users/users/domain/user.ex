defmodule MittelUsers.Users.Domain.User do
  alias MittelUsers.Shared.Types.UUID
  @enforce_keys [:id, :email, :username, :role]
  defstruct [
    :id,
    :email,
    :username,
    :password_hash,
    :role,
    :inserted_at,
    :updated_at
  ]

  @type role :: :user | :admin
  @type t :: %__MODULE__{
          id: UUID.t(),
          email: String.t(),
          username: String.t(),
          password_hash: String.t() | nil,
          role: role(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }
end
