defmodule MittelAuth.Config.Router do
  alias MittelAuth.Auth.Plugs.AuthPlug
  use MittelAuth, :router

  pipeline :api do
    plug OpenApiSpex.Plug.PutApiSpec, module: MittelAuth.ApiSpec
    plug :accepts, ["json"]
    plug :fetch_session
  end

  scope "/" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
  end

  scope "/", MittelAuth do
    pipe_through :api

    post "/introspect", Users.Application.UserController, :introspect

    scope "/users", Users.Application do
      scope "/" do
        pipe_through [AuthPlug]
        get "/self", UserController, :get_self
      end

      get "/exists/:id", UserController, :exists
      get "/:id", UserController, :show
      put "/:id", UserController, :update
      delete "/:id", UserController, :delete
    end

    scope "/auth", Auth.Application do
      post "/register", AuthController, :register
      post "/login", AuthController, :login
      post "/logout", AuthController, :logout
    end
  end
end
