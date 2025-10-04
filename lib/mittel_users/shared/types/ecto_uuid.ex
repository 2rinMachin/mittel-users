defmodule MittelUsers.Shared.Types.EctoUUID do
  use Ecto.Type

  alias MittelUsers.Shared.Types.UUID

  @impl true
  @spec type() :: :binary_id
  def type, do: :binary_id

  @impl true
  @spec cast(term()) :: {:ok, UUID.t()} | :error
  def cast(value) when is_binary(value), do: UUID.new(value)
  def cast(%UUID{} = uuid), do: {:ok, uuid}
  def cast(_), do: :error

  @impl true
  @spec load(term()) :: {:ok, UUID.t()} | :error
  def load(value) when is_binary(value), do: UUID.new(value)
  def load(_), do: :error

  @impl true
  @spec dump(UUID.t() | String.t()) :: {:ok, String.t()} | :error
  def dump(%UUID{value: value}), do: {:ok, value}

  def dump(value) when is_binary(value) do
    case UUID.new(value) do
      {:ok, %UUID{value: valid}} -> {:ok, valid}
      {:error, _} -> :error
    end
  end

  def dump(_), do: :error
end
