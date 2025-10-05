defmodule MittelUsers.Auth.Application.RegisterSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Register User",
    description: "DTO for user registration",
    type: :object,
    properties: %{
      email: %Schema{type: :string, format: :email},
      username: %Schema{type: :string},
      password: %Schema{type: :string, format: :password}
    },
    required: [:id, :username, :password]
  })
end

defmodule MittelUsers.Auth.Application.LoginRequestSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Login Request",
    type: :object,
    properties: %{
      email: %Schema{type: :string, format: :email},
      password: %Schema{type: :string, format: :password}
    },
    required: [:id, :password]
  })
end

defmodule MittelUsers.Auth.Application.LoginResponseSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Login Response",
    type: :object,
    properties: %{
      token: %Schema{type: :string},
      expires_at: %Schema{type: :string, format: :"date-time"}
    },
    required: [:token, :expires_at]
  })
end

defmodule MittelUsers.Auth.Application.TokenValidationSchema do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Token Validation Response",
    type: :object,
    properties: %{
      valid: %Schema{type: :boolean}
    },
    required: [:valid]
  })
end
