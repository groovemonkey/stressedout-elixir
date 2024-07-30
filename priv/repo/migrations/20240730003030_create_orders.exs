defmodule Stressedout.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, :integer
      add :product_id, :integer
      add :quantity, :integer
      add :total_price, :float
      add :date, :utc_datetime

      timestamps()
    end
  end
end
