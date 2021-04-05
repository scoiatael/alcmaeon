defmodule Alcmaeon do
  @moduledoc """
  Alcmaeon keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @script {:global, Alcmaeon.Script}
  @stage Alcmaeon.Stage

  alias Ecto.UUID

  def add_note(id \\ UUID.generate(), pid \\ @script, parent, text) do
    GenServer.cast(pid, {:add, parent, id, text})
  end

  def remove_note(pid \\ @script, id) do
    GenServer.cast(pid, {:remove, id})
  end

  def list_notes(pid \\ @stage) do
    with :empty <- GenServer.call(pid, :get) do
      # NOTE: We choose strong consistency here by failing to return a reply instead of defaulting to empty list
      raise "Stage returned empty response"
    else
      notes -> notes
    end
  end
end
