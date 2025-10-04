defmodule MittelUsers.Config.HealthController do
  use MittelUsers, :controller
  use OpenApiSpex.ControllerSpecs

  tags ["health"]

  operation :check, summary: "Health check"

  @spec check(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def check(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
