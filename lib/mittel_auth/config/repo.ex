defmodule MittelAuth.Repo do
  use Ecto.Repo,
    otp_app: :mittel_auth,
    adapter: Ecto.Adapters.Postgres
end
