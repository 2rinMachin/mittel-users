defmodule MittelAuth.Users.Application.UserController do
  alias MittelAuth.Users.Domain.User
  use MittelAuth, :controller

  @repo Application.compile_env!(:mittel_auth, :user_repository)
  @session_repo Application.compile_env!(:mittel_auth, :session_repository)

  def show(conn, %{"id" => id}) do
    case @repo.find_by_id(id) do
      {:ok, %User{} = user} ->
        json(conn, %{id: user.id, email: user.email, first_name: user.first_name})

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  def introspect(conn, %{"token" => token}) do
    with {:ok, session} <- @session_repo.find_by_token(token),
         {:ok, user} <- @repo.find_by_id(session.user_id),
         false <- session_expired?(session) do
      json(conn, %{
        id: user.id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name
      })
    else
      _ -> conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
    end
  end

  def get_self(conn, _params) do
    case conn.assigns[:current_user] do
      %User{} = user ->
        json(conn, %{
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        })

      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
    end
  end

  def exists(conn, %{"id" => id}) do
    case @repo.exists_by_id(id) do
      {:ok, exists} ->
        json(conn, %{exists: exists})

      {:error, _} ->
        conn |> put_status(:internal_server_error) |> json(%{error: "Internal error"})
    end
  end

  def update(conn, %{"id" => id} = params) do
    case @repo.find_by_id(id) do
      {:ok, %User{} = user} ->
        case @repo.save(Map.merge(user, params)) do
          {:ok, %User{} = updated} ->
            json(conn, %{id: updated.id, email: updated.email})

          {:error, reason} ->
            conn
            |> put_status(:bad_request)
            |> json(%{error: "Could not update user: #{inspect(reason)}"})
        end

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  def delete(conn, %{"id" => id}) do
    case @repo.delete(id) do
      :ok ->
        send_resp(conn, 204, "")

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})

      {:error, _} ->
        conn |> put_status(:internal_server_error) |> json(%{error: "Could not delete user"})
    end
  end

  defp session_expired?(session) do
    case session.expires_at do
      nil -> false
      expires_at -> NaiveDateTime.compare(expires_at, NaiveDateTime.utc_now()) == :lt
    end
  end
end
