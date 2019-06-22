defmodule Buttons do
  @moduledoc """
  Documentation for Buttons.
  """

  use GenServer

  @hook Application.get_env(:buttons, :idobata_hook)

  alias Circuits.GPIO
  require Logger

  def start_link(opts) do
    sink = Keyword.get(opts, :sink)
    GenServer.start_link(__MODULE__, %{sink: sink}, name: __MODULE__)
  end

  def init(state) do
    {:ok, i17} = GPIO.open(17, :input)
    {:ok, i27} = GPIO.open(27, :input)

    GPIO.set_interrupts(i17, :both)
    GPIO.set_interrupts(i27, :both)

    hook = ExIdobata.new_hook(@hook)

    {:ok, Map.merge(state, %{i17: i17, i27: i27, hook: hook})}
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

    send(state.sink, {:button_event, button, event})

    ExIdobata.post(state.hook, source: "button #{button} #{event}")

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
