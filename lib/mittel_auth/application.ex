defmodule MittelUsers.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      MittelUsers.Repo,
      MittelUsers.Config.Endpoint
    ]

    MittelUsers.Release.migrate()

    opts = [strategy: :one_for_one, name: MittelUsers.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MittelUsers.Config.Endpoint.config_change(changed, removed)
  end
end
