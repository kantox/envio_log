import Config

config :envio, :log,
  level: :debug,
  process_info: true

config :logger, backends: [Envio.Log.Backend], level: :debug

config :envio, :backends, %{
  Envio.IO => %{
    {Envio.Log.Publisher, :info} => []
  }
}
