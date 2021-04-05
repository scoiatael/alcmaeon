defmodule FlyioLibcluster.Region do
  use GenServer

  @name :region
  @start {}

  def fly_region do
    System.get_env("FLY_REGION", "unknown")
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @start, name: @name)
  end

  def get(node) do
    GenServer.call({@name, node}, :get)
  end

  def init(start) do
    {:ok, start}
  end

  def handle_call(:get, _from, state) do
    {:reply, fly_region(), state}
  end
end
