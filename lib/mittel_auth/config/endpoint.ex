defmodule MittelAuth.Config.Endpoint do
  use Phoenix.Endpoint, otp_app: :mittel_auth

  @session_options [
    store: :cookie,
    key: "_mittel_auth_key",
    signing_salt: System.fetch_env!("SESSION_SIGNING_SALT"),
    encryption_salt: System.fetch_env!("SESSION_ENCRYPTION_SALT"),
    same_site: "Lax",
    http_only: true,
    secure: true
  ]

  plug CORSPlug, origin: "*"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug MittelAuth.Config.Router
end

defmodule MittelAuth.Config.ErrorJSON do
  def render("500.json", _assigns) do
    %{error: "Internal server error"}
  end

  def render(_template, assigns) do
    %{error: assigns[:reason] || "Unknown error"}
  end
end
