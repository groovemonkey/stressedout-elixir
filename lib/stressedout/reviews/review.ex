defmodule Stressedout.Reviews.Review do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reviews" do
    # field :id, Ecto.UUID
    field :product_id, Ecto.UUID
    field :user_id, Ecto.UUID
    field :rating, :integer
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:id, :product_id, :user_id, :rating, :content])
    |> validate_required([:id, :product_id, :user_id, :rating, :content])
  end
end
