defmodule MittelUsers.Shared.Schemas.SimpleErrorSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Simple Error Response",
    type: :object,
    properties: %{
      error: %Schema{type: :string}
    },
    required: [:error]
  })
end
