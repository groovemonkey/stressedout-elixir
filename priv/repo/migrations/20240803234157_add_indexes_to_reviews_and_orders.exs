defmodule Stressedout.Repo.Migrations.AddIndexesToReviewsAndOrders do
  use Ecto.Migration

  def change do
    create index(:orders, [:product_id])
    create index(:orders, [:user_id])
    create index(:reviews, [:product_id])
    create index(:reviews, [:user_id])
  end
end
