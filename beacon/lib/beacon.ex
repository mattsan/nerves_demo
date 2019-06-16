defmodule Beacon do
  @moduledoc """
  Documentation for Beacon.
  """

  use GenServer

  @hook Application.get_env(:beacon, :idobata_hook)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    :timer.send_interval(10_000, :beacon)
    initialized_at = NaiveDateTime.utc_now()
    {:ok, Map.merge(state, %{initialized_at: initialized_at})}
  end

  def handle_info(:beacon, state) do
    now = NaiveDateTime.utc_now()

    @hook
    |> ExIdobata.new_hook()
    |> ExIdobata.post(source: "initialized at #{state.initialized_at}, now #{now}")

    {:noreply, state}
  end
end
