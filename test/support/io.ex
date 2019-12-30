defmodule Envio.IO do
  @moduledoc false

  @behaviour Envio.Backend

  @impl Envio.Backend
  def on_envio(message, _meta) do
    IO.puts("[★Envío Reg★]: " <> inspect({message, message[:metadata][:pid]}))

    case Process.send(message[:metadata][:pid], :on_envio_called, []) do
      :ok -> {:ok, message[:pid]}
      error -> {:error, error}
    end
  end
end
