defmodule MittelUsers.ApiSpec do
  alias OpenApiSpex.{Info, OpenApi, Paths, Server, Components, SecurityScheme}
  alias MittelUsers.Config.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "Mittel Users",
        version: "1.0"
      },
      paths: Paths.from_router(Router),
      components: %Components{
        schemas: %{},
        securitySchemes: %{
          "bearerAuth" => %SecurityScheme{
            type: :http,
            scheme: :bearer,
            description: """
            Use the `Authorization: Bearer <token>` header to authenticate.
            """
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
