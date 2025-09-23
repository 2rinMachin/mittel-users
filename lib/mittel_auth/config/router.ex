defmodule MittelAuth.Config.Router do
  alias MittelAuth.Auth.Plugs.AuthPlug
  use MittelAuth, :router

  pipeline :api do
    plug :accepts, ["json"]
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
