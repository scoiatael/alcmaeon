defmodule Alcmaeon.Script do
  use GenServer


  @initial %{root: [children: []]}
  @name Alcmaeon.Script

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.get(opts, :initial, @initial),
      name: Keyword.get(opts, :name, @name)
    )
  end

  @impl true
  def init(state) do
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
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove, id}, state) do
    # NOTE: Compaction in :add takes care of obsolete children. Is it sound?
    new_state = Map.delete(state, id)
    {:noreply, new_state}
  end
  end
end
