defmodule MittelUsers.Shared.Plugs.RequireParams do
  import Plug.Conn

  def init(required_keys), do: required_keys

  def call(conn, required_keys) do
    missing =
      required_keys |> Enum.filter(fn key -> Map.get(conn.body_params, key) in [nil, ""] end)

    if missing == [] do
      conn
    else
      conn
      |> put_status(:bad_request)
      |> Phoenix.Controller.json(%{error: "Missing required fields: #{Enum.join(missing, ", ")}"})
      |> halt()
    end
  end
end
