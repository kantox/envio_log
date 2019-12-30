defmodule Envio.Log.Test do
  use ExUnit.Case
  require Logger

  doctest Envio.Log

  test "#message is logged with registry" do
    Logger.info("hello", foo: :bar)
    assert_receive :on_envio_called, 1_000
  end
end
