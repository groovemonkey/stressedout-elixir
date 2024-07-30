defmodule Stressedout.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    # field :id, Ecto.UUID
    field :name, :string
    field :address, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name, :address])
    |> validate_required([:id, :name, :address])
  end
end
