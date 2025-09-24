import Config

config :mittel_auth,
  ecto_repos: [MittelAuth.Repo],
  generators: [timestamp_type: :utc_datetime]

config :mittel_auth, MittelAuth.Config.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MittelAuth.Config.ErrorJSON],
    layout: false
  ]

alias MittelAuth.Users.Infrastructure.EctoUserRepository
config :mittel_auth, :user_repository, EctoUserRepository

alias MittelAuth.Sessions.Infrastructure.EctoSessionRepository
config :mittel_auth, :session_repository, EctoSessionRepository

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
