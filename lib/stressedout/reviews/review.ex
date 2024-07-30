defmodule Stressedout.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    field :rating, :integer
    field :content, :string

    # field :product_id, :integer
    # field :user_id, :integer
    belongs_to :product, Stressedout.Products.Product
    belongs_to :user, Stressedout.Users.User

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:product_id, :user_id, :rating, :content])
    |> validate_required([:product_id, :user_id, :rating, :content])
    |> assoc_constraint(:user)
    |> assoc_constraint(:product)
  end
end
