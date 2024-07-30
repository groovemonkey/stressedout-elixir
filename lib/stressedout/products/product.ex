defmodule Stressedout.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    # field :id, Ecto.UUID
    field :name, :string
    field :description, :string
    field :price, :float

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:id, :name, :description, :price])
    |> validate_required([:id, :name, :description, :price])
  end
end
