defmodule Envio.Log.Backend do
  @moduledoc false

  alias Envio.Log.Publisher

  @behaviour :gen_event

  @doc false
  @impl :gen_event
  def init(__MODULE__), do: {:ok, configure(__MODULE__)}

  @doc false
  @impl :gen_event
  def handle_event(:flush, state), do: {:ok, state}

  @doc false
  @impl :gen_event
  def handle_event({level, group_leader, {Logger, message, timestamp, metadata}}, state) do
    {metadata, payload} =
      Keyword.split(metadata, [:module, :function, :file, :line, :context, :pid])

    pid = Keyword.get(metadata, :pid, group_leader)

    metadata =
      metadata
      |> Keyword.put(:group_leader, group_leader)
      |> Keyword.put(:timestamp, fix_timestamp(timestamp))

    Logger.metadata(metadata)

    process_info? = Map.get(state, :process_info, true)

    payload =
      payload
      |> Map.new()
      |> Map.put(:message, message)
      |> Map.put(:level, level)
      |> Map.put(:metadata, Map.new(metadata))
      |> Map.put(:process_info, process_info(pid, process_info?))

    Publisher.publish(level, payload)

    {:ok, state}
  end

  @impl :gen_event
  def handle_call({:configure, opts}, %{name: name} = state) do
    cfg = configure(name, opts, state)
    {:ok, cfg, cfg}
  end

  ##############################################################################

  @spec configure(name :: atom(), opts :: keyword(), state :: map()) :: map()
  defp configure(name, opts \\ [], state \\ %{}) when is_map(state) do
    config =
      :envio
      |> Application.get_env(:log, [])
      |> Keyword.merge(opts)
      |> Map.new()

    state
    |> Map.merge(config)
    |> Map.put_new(:name, name)
  end

  ##############################################################################
  @spec process_info(pid :: pid(), process_info :: true | any()) :: map() | any()
  defp process_info(pid, true) do
    pid
    |> Process.info()
    |> Kernel.||([])
    |> Map.new()
    |> Map.take([
      :status,
      :message_queue_len,
      :priority,
      :total_heap_size,
      :heap_size,
      :stack_size,
      :reductions,
      :garbage_collection
    ])
    |> Map.update!(:garbage_collection, &Map.new/1)
    |> Map.put(:schedulers, System.schedulers())
  end

  defp process_info(_pid, process_info), do: process_info

  ##############################################################################

  @spec fix_timestamp(timestamp :: nil | :calendar.datetime()) :: binary()
  @doc false
  defp fix_timestamp(nil),
    do: DateTime.utc_now() |> DateTime.truncate(:millisecond) |> DateTime.to_iso8601()

  defp fix_timestamp({{_, _, _} = d, {h, m, s, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({d, {h, m, s}}, {ms * 1_000, 3}),
         result <- NaiveDateTime.to_iso8601(timestamp) do
      "#{result}Z"
    end
  end
end
