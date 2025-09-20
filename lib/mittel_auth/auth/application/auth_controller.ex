defmodule MittelAuth.Auth.Application.AuthController do
  alias MittelAuth.Users.Domain.User
  use MittelAuth, :controller

  @user_repo Application.compile_env!(:mittel_auth, :user_repository)
  @session_repo Application.compile_env!(:mittel_auth, :session_repository)

  def register(conn, params) do
    changeset = User.changeset(%User{}, params)

    case @user_repo.save(changeset) do
      {:ok, user} ->
        conn |> put_status(:created) |> json(%{id: user.id, email: user.email})

      {:error, changeset} ->
        conn |> put_status(:bad_request) |> json(%{errors: changeset.errors})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case @user_repo.find_by_email(email) do
      {:ok, %User{} = user} ->
        if valid_password?(user, password) do
          expires_at = DateTime.add(DateTime.utc_now(), 60 * 60 * 24)
          {:ok, session} = @session_repo.create(user.id, expires_at)

          json(conn, %{token: session.token, expires_at: session.expires_at})
        else
          conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
        end

      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "User not found"})
    end
  end

  def validate(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, session} <- @session_repo.find_by_token(token) do
      if session_expired?(session) do
        json(conn, %{valid: false})
      else
        json(conn, %{valid: true})
      end
    end
  end

  def logout(conn, %{"token" => token}) do
    case @session_repo.delete(token) do
      :ok -> send_resp(conn, 204, "")
      {:error, _} -> conn |> put_status(:bad_request) |> json(%{error: "Invalid token"})
    end
  end

  defp valid_password?(%User{password: hash}, password) do
    Bcrypt.verify_pass(password, hash)
  end

  defp session_expired?(session) do
    case session.expires_at do
      nil -> false
      expires_at -> DateTime.compare(expires_at, DateTime.utc_now()) == :lt
    end
  end
end
