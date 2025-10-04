defmodule MittelUsers.Auth.Application.AuthController do
  use MittelUsers, :controller
  use OpenApiSpex.ControllerSpecs

  alias MittelUsers.Auth.Domain.AuthService

  tags ["auth"]

  operation :register, summary: "Register user", request_body: {"User params", "application/json"}

  @spec register(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def register(conn, %{"email" => email, "username" => username, "password" => password}) do
    case AuthService.register(%{
           email: email,
           username: username,
           password: password
         }) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{id: user.id, email: user.email, username: user.username})

      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: inspect(reason)})
    end
  end

  operation :login, summary: "Login user", request_body: {"User params", "application/json"}

  @spec login(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def login(conn, %{"email" => email, "password" => password}) do
    case AuthService.authenticate(email, password) do
      {:ok, user} ->
        {:ok, session} = AuthService.create_session(user)
        json(conn, %{token: session.token, expires_at: session.expires_at})

      {:error, :invalid_credentials} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
    end
  end

  operation :validate, summary: "Validate user token"

  @spec validate(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def validate(conn, _params) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      json(conn, %{valid: AuthService.validate(token)})
    end
  end

  operation :logout, summary: "Logout user"

  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization") do
      case AuthService.logout(token) do
        :ok -> send_resp(conn, 204, "")
        {:error, _} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
      end
    end
  end
end
