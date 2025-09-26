import Config

config :mittel_users,
  ecto_repos: [MittelUsers.Repo],
  generators: [timestamp_type: :utc_datetime]

config :mittel_users, MittelUsers.Config.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MittelUsers.Config.ErrorJSON],
    layout: false
  ]

alias MittelUsers.Users.Infrastructure.EctoUserRepository
config :mittel_users, :user_repository, EctoUserRepository

alias MittelUsers.Sessions.Infrastructure.EctoSessionRepository
config :mittel_users, :session_repository, EctoSessionRepository

config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
