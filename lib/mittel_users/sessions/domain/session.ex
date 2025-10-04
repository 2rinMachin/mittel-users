defmodule MittelUsers.Sessions.Domain.UserSession do
  alias MittelUsers.Shared.Types.UUID
  @enforce_keys [:id, :user_id, :token]
  defstruct [
    :id,
    :user_id,
    :token,
    :expires_at,
    :inserted_at
  ]

  @type t :: %__MODULE__{
          id: UUID.t(),
          user_id: UUID.t(),
          token: String.t(),
          expires_at: DateTime.t(),
          inserted_at: DateTime.t()
        }
end
