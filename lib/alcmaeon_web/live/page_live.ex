defmodule AlcmaeonWeb.PageLive do
  use AlcmaeonWeb, :live_view
  alias Phoenix.PubSub
  alias Alcmaeon.{Note, Stage}

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(Alcmaeon.PubSub, Alcmaeon.Script.topic())
    {:ok, assign(socket, notes: Alcmaeon.list_notes(), modal: false)}
  end

  @impl true
  def handle_event("add", values, socket) do
    {:noreply,
     assign(socket,
       modal: true,
       modal_for: Map.get(values, "id", :root),
       changeset: Note.changeset()
     )}
  end

  @impl true
  def handle_event(
        "save",
        %{"note" => note_params},
        %{assigns: %{modal_for: parent}} = socket
      ) do
    with {:ok, %{text: text}} <- Note.apply(note_params) do
      Alcmaeon.add_note(parent, text)
      {:noreply, assign(socket, modal: false)}
    else
      {:error, changeset} -> {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("remove", %{"id" => id}, socket) do
    Alcmaeon.remove_note(id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:notes, notes}, socket) do
    {:noreply, assign(socket, notes: Stage.view(notes))}
  end

  def render_notes(assigns) do
    ~L"""
    <ul>
    <%= for %{text: text, children: children, id: id} <- @notes do %>
        <li>
          <span><%= text %></span>
          <button type="submit" phx-disable-with="..." phx-click="add" phx-value-id="<%= id %>">+</button>
          <button type="submit" phx-disable-with="..." phx-click="remove" phx-value-id="<%= id %>">-</button>
        </li>
        <%= render_notes(%{ assigns | notes: children}) %>
    <% end %>
    </ul>
    """
  end
end
