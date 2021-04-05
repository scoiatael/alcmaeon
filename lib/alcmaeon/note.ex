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
    |> validate_length(:text, min: 1, max: 120)
  end

  def apply(params) do
    %Alcmaeon.Note{}
    |> changeset(params)
    |> apply_action(:apply)
  end
end
