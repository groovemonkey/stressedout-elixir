defmodule Stressedout.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      # add :id, :uuid
      add :user_id, :uuid
      add :product_id, :uuid
      add :quantity, :integer
      add :total_price, :float
      add :date, :utc_datetime

      timestamps()
    end
  end
end
