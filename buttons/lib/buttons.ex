defmodule Buttons do
  @moduledoc """
  Documentation for Buttons.
  """

  use GenServer

  alias Circuits.GPIO
  require Logger

  def start_link(opts) do
    handler = Keyword.get(opts, :handler, fn _event, _button -> nil end)
    GenServer.start_link(__MODULE__, %{handler: handler}, name: __MODULE__)
  end

  def init(state) do
    {:ok, i17} = GPIO.open(17, :input)
    {:ok, i27} = GPIO.open(27, :input)

    GPIO.set_interrupts(i17, :both)
    GPIO.set_interrupts(i27, :both)

    {:ok, Map.merge(state, %{i17: i17, i27: i27})}
  end

  def handle_info({:circuits_gpio, pin, _timestamp, value}, state) do
    button =
      case pin do
        17 -> "right"
        27 -> "left"
        _  -> "unkonwn"
      end

    event =
      case value do
        0 -> "released"
        1 -> "pressed"
      end

    # WebMonitorWeb.Endpoint.broadcast("room:lobby", event, %{button: button})
    state.handler.(event, button)

    {:noreply, state}
  end

  def handle_info(event, state) do
    Logger.info("unkonwn event: #{inspect(event)}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.info("teminated. reason: #{inspect(reason)}, state: #{inspect(state)}")
  end
end
