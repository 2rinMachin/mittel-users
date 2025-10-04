defmodule MittelUsers.Repo do
  use Ecto.Repo,
    otp_app: :mittel_users,
    adapter: Ecto.Adapters.Postgres
end
