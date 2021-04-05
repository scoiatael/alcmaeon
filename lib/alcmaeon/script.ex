defmodule Alcmaeon.Script do
  use GenServer

  alias Phoenix.PubSub

  @initial %{root: [children: []]}
  @name Alcmaeon.Script

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      Keyword.get(opts, :initial, @initial),
      name: Keyword.get(opts, :name, @name)
    )
  end

  def topic, do: "alcmaeon_script_notes"

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

    PubSub.broadcast(Alcmaeon.PubSub, topic(), {:notes, view(new_state)})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:remove, id}, state) do
    # NOTE: Compaction in :add takes care of obsolete children. Is it sound?
    new_state = Map.delete(state, id)

    PubSub.broadcast(Alcmaeon.PubSub, topic(), {:notes, view(new_state)})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get, _from, state), do: {:reply, view(state), state}

  defp view(state), do: unfold(state, :root)[:children]

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
