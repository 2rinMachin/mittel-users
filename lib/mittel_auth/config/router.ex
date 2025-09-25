defmodule MittelAuth.Config.Router do
  alias MittelAuth.Auth.Plugs.AuthPlug
  use MittelAuth, :router

  pipeline :api do
    plug OpenApiSpex.Plug.PutApiSpec, module: MittelAuth.ApiSpec
    plug :accepts, ["json"]
    plug :fetch_session
  end

  # scope "/" do
  #   pipe_through :browser
  #
  #   get "/swagger", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
  # end

  scope "/" do
    pipe_through :api

    get "/openapi.json", OpenApiSpex.Plug.RenderSpec, []
    get "/docs", OpenApiSpex.Plug.SwaggerUI, path: "/openapi.json"
  end

  scope "/", MittelAuth do
    pipe_through :api

    scope "/users", Users.Application do
      get "/:id", UserController, :show
      get "/exists/:id", UserController, :exists
      put "/:id", UserController, :update
      delete "/:id", UserController, :delete

      scope "/" do
        pipe_through [AuthPlug]
        get "/self", UserController, :get_self
      end
    end

    scope "/auth", Auth.Application do
      post "/register", AuthController, :register
      post "/login", AuthController, :login
      post "/logout", AuthController, :logout
    end
  end
end
