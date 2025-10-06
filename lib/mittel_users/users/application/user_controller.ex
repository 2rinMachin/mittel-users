defmodule MittelUsers.Users.Application.UserController do
  use MittelUsers, :controller
  use OpenApiSpex.ControllerSpecs

  alias MittelUsers.Users.Application.UpdateUserSchema
  alias MittelUsers.Users.Application.ExistsSchema
  alias MittelUsers.Users.Application.IntrospectTokenSchema
  alias MittelUsers.Shared.Schemas.SimpleErrorSchema
  alias MittelUsers.Users.Application.UserSchema
  alias MittelUsers.Users.Domain.{User, UserService}
  alias MittelUsers.Shared.Types.UUID

  tags ["users"]

  operation :show,
    summary: "Get user by ID",
    parameters: [id: [in: :path, description: "User UUID", type: :string, required: true]],
    responses: %{
      200 => {"User found", "application/json", UserSchema},
      400 => {"Invalid UUID", "application/json", SimpleErrorSchema},
      404 => {"User not found", "application/json", SimpleErrorSchema}
    },
    security: [%{"bearerAuth" => []}]

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    with {:ok, uuid} <- UUID.new(id),
         {:ok, %User{} = user} <- UserService.get_user(uuid) do
      json(conn, %{id: user.id, email: user.email, username: user.username, role: user.role})
    else
      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  operation :introspect,
    summary: "Introspect a session token",
    request_body: {"Token to validate", "application/json", IntrospectTokenSchema},
    responses: %{
      200 => {"User info", "application/json", UserSchema},
      400 => {"Missing/Malformed token", "application/json", SimpleErrorSchema},
      401 => {"Token expired", "application/json", SimpleErrorSchema}
    }

  @spec introspect(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def introspect(conn, params) do
    case extract_token(params) do
      {:ok, token} ->
        case UserService.introspect(token) do
          {:ok, user} ->
            json(conn, %{id: user.id, email: user.email, username: user.username, role: user.role})

          {:error, :expired} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Token expired"})

          {:error, :invalid_token} ->
            conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
        end

      {:error, :malformed} ->
        conn |> put_status(:bad_request) |> json(%{error: "Malformed token"})

      {:error, :missing} ->
        conn |> put_status(:bad_request) |> json(%{error: "Missing 'token' field"})
    end
  end

  operation :get_self,
    summary: "Get current user info",
    responses: %{
      200 => {"User info", "application/json", UserSchema},
      401 => {"Unauthorized", "application/json", SimpleErrorSchema}
    },
    security: [%{"bearerAuth" => []}]

  @spec get_self(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_self(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case UserService.introspect(token) do
          {:ok, %User{} = user} ->
            json(conn, %{id: user.id, email: user.email, username: user.username, role: user.role})

          {:error, :invalid_token} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid token"})

          {:error, :expired} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Token expired"})
        end

      [] ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Client not authenticated"})
    end
  end

  operation :find_by_username,
    summary: "Find user by username",
    parameters: [
      username: [in: :path, description: "User username", type: :string, required: true]
    ],
    responses: %{
      200 => {"User found", "application/json", UserSchema},
      404 => {"User not found", "application/json", SimpleErrorSchema}
    }

  @spec find_by_username(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def find_by_username(conn, %{"username" => username}) do
    case UserService.get_user_by_username(username) do
      {:ok, user} ->
        json(conn, %{
          id: user.id,
          email: user.email,
          username: user.username,
          role: user.role
        })

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  operation :exists,
    summary: "Check if user exists by ID",
    parameters: [
      id: [in: :path, description: "User UUID", type: :string, required: true]
    ],
    responses: %{
      200 => {"Exists", "application/json", ExistsSchema},
      400 => {"invalid UUID", "application/json", SimpleErrorSchema}
    }

  @spec exists(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def exists(conn, %{"id" => id}) do
    with {:ok, uuid} <- UUID.new(id),
         {:ok, exists} <- UserService.exists?(uuid) do
      json(conn, %{exists: exists})
    else
      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID"})

      {:error, _} ->
        conn |> put_status(:internal_server_error) |> json(%{error: "Internal error"})
    end
  end

  operation :update,
    summary: "Update current user info",
    request_body: {"User update params", "application/json", UpdateUserSchema},
    responses: %{
      200 => {"Updated", "application/json", UserSchema},
      400 => {"Malformed header", "application/json", SimpleErrorSchema},
      401 => {"Unauthorized", "application/json", SimpleErrorSchema},
      404 => {"User not found", "application/json", SimpleErrorSchema}
    },
    security: [%{"bearerAuth" => []}]

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        with {:ok, %User{id: id}} <- UserService.introspect(token),
             {:ok, %User{} = updated} <- UserService.update(id, params) do
          json(conn, %{
            id: updated.id,
            email: updated.email,
            username: updated.username,
            role: updated.role
          })
        else
          {:error, :invalid_token} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Invalid token"})

          {:error, :expired} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Token expired"})

          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "User not found"})

          {:error, reason} ->
            conn |> put_status(:internal_server_error) |> json(%{error: inspect(reason)})
        end

      [_other] ->
        conn |> put_status(:bad_request) |> json(%{error: "Malformed header"})

      [] ->
        conn |> put_status(:unauthorized) |> json(%{error: "Client not authenticated"})
    end
  end

  operation :promote,
    summary: "Promote existing user to admin",
    parameters: [
      id: [in: :path, description: "User UUID", type: :string, required: true]
    ],
    responses: %{
      200 => {"User promoted", "application/json", UserSchema},
      400 => {"Bad request", "application/json", SimpleErrorSchema},
      401 => {"Unauthorized", "application/json", SimpleErrorSchema},
      403 => {"Forbidden", "application/json", SimpleErrorSchema},
      404 => {"User not found", "application/json", SimpleErrorSchema}
    },
    security: [%{"bearerAuth" => []}]

  @spec promote(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def promote(conn, %{"id" => id}) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        with {:ok, user} <- UserService.introspect(token),
             :ok <- ensure_admin(user),
             {:ok, updated} <- UserService.promote_to_admin(%UUID{value: id}) do
          json(conn, %{
            id: updated.id,
            email: updated.email,
            username: updated.username,
            role: updated.role
          })
        else
          {:error, :not_admin} ->
            conn |> put_status(:forbidden) |> json(%{error: "Endpoint only allowed for admins"})

          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "User to promote not found"})

          {:error, :invalid_token} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Invalid token"})

          {:error, :expired} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Token expired"})
        end

      [_other] ->
        conn |> put_status(:bad_request) |> json(%{error: "Malformed header"})

      [] ->
        conn |> put_status(:unauthorized) |> json(%{error: "Client not authenticated"})
    end
  end

  operation :delete,
    summary: "Delete current user",
    responses: %{
      204 => {"Deleted", "application/json", nil},
      400 => {"Malformed header", "application/json", SimpleErrorSchema},
      401 => {"Client not authenticated", "application/json", SimpleErrorSchema},
      404 => {"User not found", "application/json", SimpleErrorSchema}
    },
    security: [%{"bearerAuth" => []}]

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        with {:ok, %User{id: id}} <- UserService.introspect(token),
             :ok <- UserService.delete(id) do
          send_resp(conn, 204, "")
        else
          {:error, :invalid_token} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Invalid token"})

          {:error, :expired} ->
            conn |> put_status(:unauthorized) |> json(%{error: "Token expired"})

          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "User not found"})

          {:error, _} ->
            conn |> put_status(:internal_server_error) |> json(%{error: "Could not delete user"})
        end

      [_other] ->
        conn |> put_status(:bad_request) |> json(%{error: "Malformed header"})

      [] ->
        conn |> put_status(:unauthorized) |> json(%{error: "Client not authenticated"})
    end
  end

  @spec get_all_by_pattern(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_all_by_pattern(conn, %{"pattern" => partial}) do
    users = UserService.search_by_pattern(partial)

    json(
      conn,
      Enum.map(users, fn user ->
        %{
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role
        }
      end)
    )
  end

  @spec ensure_admin(User.t()) :: :ok | {:error, :not_admin}
  defp ensure_admin(%{role: :admin}), do: :ok
  defp ensure_admin(_), do: {:error, :not_admin}

  @spec extract_token(map()) :: {:ok, String.t()} | {:error, :malformed} | {:error, :missing}
  defp extract_token(%{"token" => "Bearer " <> token}), do: {:ok, token}
  defp extract_token(%{"token" => _other}), do: {:error, :malformed}
  defp extract_token(_params), do: {:error, :missing}
end
