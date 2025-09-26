defmodule MittelAuth.Auth.Application.AuthController do
  alias MittelAuth.Users.Domain.UserSchema.UserParams
  alias MittelAuth.Config.ChangesetView
  alias MittelAuth.Users.Domain.User
  use MittelAuth, :controller
  use OpenApiSpex.ControllerSpecs

  @user_repo Application.compile_env!(:mittel_auth, :user_repository)
  @session_repo Application.compile_env!(:mittel_auth, :session_repository)

  tags ["auth"]

  operation :register,
    summary: "Register user",
    parameters: [
      email: [in: :path, description: "User email", type: :string, example: "alice@example.com"],
      password: [in: :path, description: "User password", type: :string, example: "secret123"],
      first_name: [in: :path, description: "User first name", type: :string, example: "Alice"],
      last_name: [in: :path, description: "User last name", type: :string, example: "Doe"]
    ],
    request_body: {"User params", "application/json", UserParams}

  def register(conn, params) do
    changeset = User.changeset(%User{}, params)

    case @user_repo.save(changeset) do
      {:ok, user} ->
        conn |> put_status(:created) |> json(%{id: user.id, email: user.email})

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: ChangesetView.translate_errors(changeset)})
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case @user_repo.find_by_email(email) do
      {:ok, %User{} = user} ->
        if valid_password?(user, password) do
          expires_at = DateTime.add(DateTime.utc_now(), 60 * 60 * 24)
          {:ok, session} = @session_repo.create(user.id, expires_at)

          conn |> json(%{token: session.token, expires_at: session.expires_at})
        else
          conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
        end

      {:error, :not_found} ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})
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

  defp valid_password?(%User{password_hash: nil}, _password) do
    Bcrypt.no_user_verify()
  end

  defp valid_password?(%User{password_hash: hash}, password) do
    Bcrypt.verify_pass(password, hash)
  end

  defp session_expired?(session) do
    case session.expires_at do
      nil -> false
      expires_at -> NaiveDateTime.compare(expires_at, NaiveDateTime.utc_now()) == :lt
    end
  end
end
