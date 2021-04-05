defmodule Alcmaeon do
  @moduledoc """
  Alcmaeon keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @name {:global, Alcmaeon.Script}

  alias Ecto.UUID

  def add_note(id \\ UUID.generate(), pid \\ @name, parent, text) do
    GenServer.cast(pid, {:add, parent, id, text})
  end

  def remove_note(pid \\ @name, id) do
    GenServer.cast(pid, {:remove, id})
  end

  def list_notes(pid \\ @name) do
    GenServer.call(pid, :get)
  end
end
