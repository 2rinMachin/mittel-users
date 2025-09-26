defmodule MittelUsers.Users.Domain.UserSchema do
  alias OpenApiSpex.Schema

  defmodule User do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of the app",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID"},
        email: %Schema{type: :string, description: "Email address", format: :email},
        first_name: %Schema{
          type: :string,
          description: "User first name",
          pattern: ~r/[a-zA-Z][a-zA-Z0-9_]+/
        },
        last_name: %Schema{
          type: :string,
          description: "User last name",
          pattern: ~r/[a-zA-Z][a-zA-Z0-9_]+/
        },
        inserted_at: %Schema{
          type: :string,
          description: "Creation timestamp",
          format: :"date-time"
        },
        updated_at: %Schema{type: :string, description: "Update timestamp", format: :"date-time"}
      },
      required: [:id, :email],
      example: %{
        "id" => 123,
        "email" => "joe@gmail.com",
        "first_name" => "Joe",
        "last_name" => "Doe",
        "inserted_at" => "2017-09-12T12:34:55Z",
        "updated_at" => "2017-09-13T10:11:12Z"
      }
    })
  end

  defmodule UserParams do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "User Parameters",
      description: "Request schema for single user",
      type: :object,
      properties: %{
        data: User
      },
      example: %{
        "data" => %{
          "id" => 123,
          "email" => "joe@gmail.com",
          "first_name" => "Joe",
          "last_name" => "Doe",
          "inserted_at" => "2017-09-12T12:34:55Z",
          "updated_at" => "2017-09-13T10:11:12Z"
        }
      }
    })
  end
end
