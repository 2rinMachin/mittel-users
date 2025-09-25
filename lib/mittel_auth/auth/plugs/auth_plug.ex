defmodule MittelAuth.Auth.Plugs.AuthPlug do
  import Plug.Conn

  @user_repo Application.compile_env!(:mittel_auth, :user_repository)
  @session_repo Application.compile_env!(:mittel_auth, :session_repository)

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, session} <- @session_repo.find_by_token(token),
         {:ok, user} <- @user_repo.find_by_id(session.user_id),
         false <- session_expired?(session) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "Unauthorized")
        |> halt()
    end
  end

  defp session_expired?(session) do
    case session.expires_at do
      nil -> false
      expires_at -> NaiveDateTime.compare(expires_at, NaiveDateTime.utc_now()) == :lt
    end
  end
end
