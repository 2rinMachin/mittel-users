defmodule MittelUsers.Auth.Application.AuthController do
  use MittelUsers, :controller
  use OpenApiSpex.ControllerSpecs

  plug MittelUsers.Shared.Plugs.RequireParams,
       ["email", "username", "password"] when action in [:register]

  plug MittelUsers.Shared.Plugs.RequireParams, ["email", "password"] when action in [:login]

  alias MittelUsers.Auth.Application.TokenValidationSchema
  alias MittelUsers.Shared.Schemas.SimpleErrorSchema
  alias MittelUsers.Auth.Application.LoginResponseSchema
  alias MittelUsers.Auth.Application.LoginRequestSchema
  alias MittelUsers.Auth.Application.RegisterSchema
  alias MittelUsers.Users.Application.UserSchema
  alias MittelUsers.Auth.Domain.AuthService

  tags ["auth"]

  operation :register,
    summary: "Register a new user",
    request_body: {"User params", "application/json", RegisterSchema},
    responses: %{
      201 => {"Created", "application/json", UserSchema},
      400 => {"Bad request", "application/json", nil}
    }

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
        |> json(%{id: user.id, email: user.email, username: user.username, role: user.role})

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = render_errors(changeset)
        conn |> put_status(:bad_request) |> json(%{errors: errors})

      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: inspect(reason)})
    end
  end

  operation :login,
    summary: "Login user",
    request_body: {"User params", "application/json", LoginRequestSchema},
    responses: %{
      200 => {"Logged in", "application/json", LoginResponseSchema},
      400 => {"Missing fields", "application/json", SimpleErrorSchema},
      401 => {"Invalid credentials", "application/json", SimpleErrorSchema}
    }

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

  operation :validate,
    summary: "Validate user token",
    parameters: [],
    security: [%{"bearerAuth" => []}],
    responses: %{
      200 => {"Token validation result", "application/json", TokenValidationSchema},
      400 => {"Malformed header", "application/json", SimpleErrorSchema},
      401 => {"Client not authenticated", "application/json", SimpleErrorSchema}
    }

  @spec validate(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def validate(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> json(conn, %{valid: AuthService.validate(token)})
      [_other] -> conn |> put_status(:bad_request) |> json(%{error: "Malformed header"})
      [] -> conn |> put_status(:unauthorized) |> json(%{error: "Client not authenticated"})
    end
  end

  operation :logout,
    summary: "Logout user",
    security: [%{"bearerAuth" => []}],
    responses: %{
      204 => {"Logged out", "application/json", nil},
      400 => {"Invalid/Malformed token", "application/json", SimpleErrorSchema},
      401 => {"Client not authenticated", "application/json", SimpleErrorSchema}
    }

  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case AuthService.logout(token) do
          :ok -> send_resp(conn, 204, "")
          {:error, _} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
        end

      [_other] ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Malformed header"})

      [] ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Client not authenticated"})
    end
  end

  @spec render_errors(Ecto.Changeset.t()) :: Ecto.Changeset.traverse_result()
  defp render_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
