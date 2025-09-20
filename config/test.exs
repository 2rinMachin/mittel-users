import Config

config :mittel_auth, MittelAuth.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "mittel_auth_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :mittel_auth, MittelAuthWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "KtpFfttNhTDkRRa5rSwxF20IcIMTYrjZTAWa44LHe/ranV8BxafQXio8IAraM+/W",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true
