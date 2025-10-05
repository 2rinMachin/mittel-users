defmodule MittelUsers.Users.Application.UserSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User Response",
    description: "A user in the system",
    type: :object,
    properties: %{
      id: %Schema{type: :string, format: :uuid},
      email: %Schema{type: :string, format: :email},
      username: %Schema{type: :string}
    },
    required: [:id, :email, :username]
  })
end

defmodule MittelUsers.Users.Application.UpdateUserSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User Update Request",
    description: "Request body for user data update",
    type: :object,
    properties: %{
      email: %Schema{type: :string, format: :email},
      username: %Schema{type: :string}
    },
    required: []
  })
end

defmodule MittelUsers.Users.Application.ExistsSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User Exists Response",
    description: "Response indicating if a user exists",
    type: :object,
    properties: %{
      exists: %Schema{type: :boolean}
    },
    required: [:exists]
  })
end

defmodule MittelUsers.Users.Application.IntrospectTokenSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Token to Introspect",
    description: "Request body for token introspection",
    type: :object,
    properties: %{
      token: %Schema{type: :string}
    },
    required: [:token]
  })
end
