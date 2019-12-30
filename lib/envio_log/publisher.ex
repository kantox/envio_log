defmodule Envio.Log.Publisher do
  @moduledoc false
  use Envio.Publisher

  @level :envio
         |> Application.get_env(:log, [])
         |> Keyword.get(:level, :info)

  @compile {:inline, publish: 2}

  @spec publish(channel :: Logger.level(), what :: map()) :: :ok
  Enum.each([:debug, :info, :warn, :error], fn level ->
    if Logger.compare_levels(@level, level) != :gt do
      def publish(unquote(level), what) do
        what
        |> update_in([:metadata, :pid], &pid_to_binary/1)
        |> update_in([:metadata, :group_leader], &pid_to_binary/1)

        broadcast(unquote(level), what)
      end
    end
  end)

  def publish(_channel, _what), do: :ok

  @spec pid_to_binary(pid :: pid()) :: binary()
  defp pid_to_binary(pid), do: "#{:erlang.pid_to_list(pid)}"
end
