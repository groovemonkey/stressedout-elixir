defmodule Stressedout.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    # field :id, Ecto.UUID
    field :date, :utc_datetime
    field :user_id, Ecto.UUID
    field :product_id, Ecto.UUID
    field :quantity, :integer
    field :total_price, :float

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:id, :user_id, :product_id, :quantity, :total_price, :date])
    |> validate_required([:id, :user_id, :product_id, :quantity, :total_price, :date])
  end
end
