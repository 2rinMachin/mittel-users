defmodule MittelUsers.Config.Router do
  use MittelUsers, :router

  pipeline :api do
    plug OpenApiSpex.Plug.PutApiSpec, module: MittelUsers.ApiSpec
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
  end

  scope "/", MittelUsers.Config do
    get "/", HealthController, :check
  end

  scope "/", MittelUsers do
    pipe_through :api

    post "/introspect", Users.Application.UserController, :introspect

    scope "/users", Users.Application do
      get "/self", UserController, :get_self
      put "/self", UserController, :update
      delete "/self", UserController, :delete

      get "/exists/:id", UserController, :exists
      get "/by_username/:username", UserController, :find_by_username

      get "/:id", UserController, :show
    end

    scope "/auth", Auth.Application do
      post "/register", AuthController, :register
      post "/login", AuthController, :login
      get "/validate", AuthController, :validate
      post "/logout", AuthController, :logout
    end
  end
end
