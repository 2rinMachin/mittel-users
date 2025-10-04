defmodule MittelUsers.Config.Endpoint do
  use Phoenix.Endpoint, otp_app: :mittel_users

  plug CORSPlug, origin: "*"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug MittelUsers.Config.Router
end

defmodule MittelUsers.Config.ErrorJSON do
  def render("404.json", %{reason: %Phoenix.Router.NoRouteError{} = reason}) do
    %{error: "Not found", message: reason.message}
  end

  def render("404.json", _assigns) do
    %{error: "Not found"}
  end

  def render("500.json", _assigns) do
    %{error: "Internal server error"}
  end

  def render(_template, %{reason: reason}) when is_exception(reason) do
    %{error: "Unhandled error", message: Exception.message(reason)}
  end

  def render(_template, _assigns) do
    %{error: "Unknown error"}
  end
end
