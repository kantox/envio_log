# ![Envio.Log](/stuff/logo-48x48.png?raw=true) `Envio.Log`

**[Logger backend](https://hexdocs.pm/logger/Logger.html#module-backends) for [`Envío`](http://hexdocs.pm/envio) with _Slack_ logging out of the box**

## Installation

```elixir
def deps do
  [
    {:envio_log, "~> 0.1"}
  ]
end
```

## Usage

Put this into your `config/prod.exs`

```elixir
import Config

config :envio, :log,
  level: :warn,
  process_info: true

config :logger, backends: [Envio.Log.Backend], level: :debug

config :envio, :backends, %{
  Envio.Slack => %{
    {Envio.Log.Publisher, :info} => [
      hook_url: {:system, "YOUR_SLACK_CHANNEL_API_ENDPOINT}
    ]
  }
}
```

You are all set! All the calls like:

```elixir
Logger.warn "Something happened", foo: :bar, answer: 42
```

will be automatically routed to the configured _Slack_ channel. All the calls to `Logger` with levels of the less priority than it was configured under `:envio, :log, :level` key will be purged in compile time.


## [Documentation](https://hexdocs.pm/envio_log).

