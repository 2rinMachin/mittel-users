defmodule MittelAuth.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      MittelAuth.Repo,
      MittelAuth.Config.Endpoint
    ]

    MittelAuth.Release.migrate()

    opts = [strategy: :one_for_one, name: MittelAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    MittelAuth.Config.Endpoint.config_change(changed, removed)
  end
end
