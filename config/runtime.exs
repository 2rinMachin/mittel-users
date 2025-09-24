import Config

if System.get_env("PHX_SERVER") do
  config :mittel_auth, MittelAuth.Config.Endpoint, server: true
end

database_url = System.fetch_env!("DATABASE_URL")

maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

config :mittel_auth, MittelAuth.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE", "10")),
  socket_options: maybe_ipv6

secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

host = System.get_env("PHX_HOST") || "localhost"
port = String.to_integer(System.get_env("PORT", "4000"))

config :mittel_auth, MittelAuth.Config.Endpoint,
  url: [host: host, port: 4000, scheme: "http"],
  http: [
    # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: port
  ],
  secret_key_base: secret_key_base

config :open_api_spex, :cache_adapter, OpenApiSpex.Plug.NoneCache
