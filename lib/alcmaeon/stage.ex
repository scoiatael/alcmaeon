defmodule Alcmaeon.Stage do
  use GenServer
  require Logger

  alias Phoenix.PubSub

  @name Alcmaeon.Stage
  @script Alcmaeon.Script

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: Keyword.get(opts, :name, @name)
    )
  end

  @impl true
  def init(_) do
    PubSub.subscribe(Alcmaeon.PubSub, Alcmaeon.Script.topic())

    {:ok, get_initial_state()}
  end

  @impl true
  def handle_info({:notes, notes}, _state) do
    {:noreply, notes}
  end

  @impl true
  def handle_call(:get, _from, :empty) do
    state = get_initial_state()

    {:reply, view(state), state}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, view(state), state}

  defp get_initial_state do
    {replies, bad_nodes} =
      GenServer.multi_call(Node.list([:this, :connected]), @script, :get, 4000)

    if Enum.empty?(replies) do
      Logger.warn("Stage: no primary state received; got bad replies from #{inspect(bad_nodes)}")
      :empty
    else
      Logger.info("Stage: received initial state: #{inspect(replies)}")
      [{_node, value} | _] = replies
      value
    end
  end

  def view(state), do: unfold(state, :root)[:children]

  defp unfold(state, id) do
    if Map.has_key?(state, id) do
      children = Keyword.get(state[id], :children, [])

      %{
        text: Keyword.get(state[id], :text),
        children: Enum.map(children, &unfold(state, &1)),
        id: id
      }
    else
      nil
    end
  end
end
