defmodule Envio.Log do
  @moduledoc """
  [Logger backend](https://hexdocs.pm/logger/Logger.html#module-backends) for [`Envío`](http://hexdocs.pm/envio) with `Slack` logging out of the box.
  """

  defdelegate publish(channel, what), to: Envio.Log.Publisher
end
