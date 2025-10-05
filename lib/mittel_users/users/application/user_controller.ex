defmodule MittelUsers.Users.Application.UserController do
  alias MittelUsers.Users.Domain.{User, UserService}
  alias MittelUsers.Shared.Types.UUID

  use MittelUsers, :controller

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    with {:ok, uuid} <- UUID.new(id),
         {:ok, %User{} = user} <- UserService.get_user(uuid) do
      json(conn, %{id: user.id, email: user.email, username: user.username})
    else
      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  @spec introspect(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def introspect(conn, %{"token" => "Bearer " <> token}) do
    case UserService.introspect(token) do
      {:ok, %User{} = user} ->
        json(conn, %{id: user.id, email: user.email, username: user.username})

      {:error, :expired} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Token expired"})

      {:error, :invalid_token} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
    end
  end

  @spec get_self(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_self(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case UserService.introspect(token) do
          {:ok, %User{} = user} ->
            json(conn, %{id: user.id, email: user.email, username: user.username})

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

  @spec find_by_username(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def find_by_username(conn, %{"username" => username}) do
    case UserService.get_user_by_username(username) do
      {:ok, user} ->
        json(conn, %{
          id: user.id,
          email: user.email,
          username: user.username
        })

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

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

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = params) do
    with {:ok, uuid} <- UUID.new(id),
         {:ok, %User{} = updated} <- UserService.update(uuid, params) do
      json(conn, %{id: updated.id, email: updated.email, username: updated.username})
    else
      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      {:error, reason} ->
        conn |> put_status(:bad_request) |> json(%{error: inspect(reason)})
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    with {:ok, uuid} <- UUID.new(id),
         :ok <- UserService.delete(uuid) do
      send_resp(conn, 204, "")
    else
      {:error, :invalid_uuid} ->
        conn |> put_status(:bad_request) |> json(%{error: "Invalid UUID"})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      {:error, _} ->
        conn |> put_status(:internal_server_error) |> json(%{error: "Could not delete user"})
    end
  end
end
