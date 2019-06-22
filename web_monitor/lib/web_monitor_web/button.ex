defmodule WebMonitorWeb.Button do
  use GenServer

  @name __MODULE__

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_info({:button_event, button, event}, state) do
    WebMonitorWeb.Endpoint.broadcast("room:lobby", event, %{button: button})
    {:noreply, state}
  end
end
