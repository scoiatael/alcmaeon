defmodule Alcmaeon.Note do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :text, :string
  end

  def changeset(module \\ %Alcmaeon.Note{}, params \\ %{}) do
    module
    |> cast(params, [:text])
    |> validate_required([:text])
  end
end
