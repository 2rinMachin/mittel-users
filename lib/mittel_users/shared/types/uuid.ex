defmodule MittelUsers.Shared.Types.UUID do
  @enforce_keys [:value]
  defstruct [:value]

  @type t :: %__MODULE__{value: String.t()}

  @uuid_regex ~r/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

  @spec new(String.t()) :: {:ok, t()} | {:error, :invalid_uuid}
  def new(str) when is_binary(str) do
    if String.match?(str, @uuid_regex) do
      {:ok, %__MODULE__{value: str}}
    else
      {:error, :invalid_uuid}
    end
  end

  @spec generate() :: t()
  def generate do
    {:ok, uuid} = new(UUID.uuid4())
    uuid
  end

  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{value: v}), do: v

  defimpl Jason.Encoder do
    alias MittelUsers.Shared.Types.UUID

    def encode(%UUID{value: value}, opts) do
      Jason.Encode.string(value, opts)
    end
  end
end
