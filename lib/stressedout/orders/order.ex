defmodule Stressedout.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :date, :utc_datetime
    field :quantity, :integer
    field :total_price, :float

    belongs_to :user, Stressedout.Users.User
    belongs_to :product, Stressedout.Products.Product

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :product_id, :quantity, :total_price, :date])
    |> validate_required([:user_id, :product_id, :quantity, :total_price, :date])
    |> assoc_constraint(:user)
    |> assoc_constraint(:product)
  end
end
