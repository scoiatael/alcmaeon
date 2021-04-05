defmodule Alcmaeon.Script do
  use GenServer

  alias Phoenix.PubSub
  require Logger

  @initial %{root: [children: []]}
  @name {:global, Alcmaeon.Script}

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.get(opts, :initial, @initial),
      name: Keyword.get(opts, :name, @name)
    )
  end

  def topic, do: "alcmaeon_script_notes"

  @impl true
  def init(initial_state) do
    # Required for multi_call in Stage.get_initial_state/0
    Process.register(self(), Alcmaeon.Script)

    {all_replies, bad_nodes} = GenServer.multi_call(Node.list(), Alcmaeon.Stage, :get, 5000)
    replies = Enum.filter(all_replies, fn {_, v} -> v != :empty end)

    state =
      if Enum.empty?(replies) do
        Logger.warn("""
        Script: no replica state received;
          got bad replies from #{inspect(bad_nodes)}
          and empty ones #{inspect(all_replies)}
        """)

        initial_state
      else
        Logger.info("Script: received initial state: #{inspect(replies)}")
        [{_node, value} | _] = replies
        value
      end

    {:ok, state}
  end

  @impl true
  def handle_cast({:add, parent, id, text}, state) do
    new_state =
      state
      |> Map.put(id, children: [], text: text)
      |> Map.update!(
        parent,
        &Keyword.update!(&1, :children, fn list ->
          [id | list] |> Enum.filter(fn child -> child == id || Map.has_key?(state, child) end)
        end)
      )

    PubSub.broadcast(Alcmaeon.PubSub, topic(), {:notes, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove, id}, state) do
    # NOTE: Compaction in :add takes care of obsolete children. Is it sound?
    new_state = Map.delete(state, id)

    PubSub.broadcast(Alcmaeon.PubSub, topic(), {:notes, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}
end
