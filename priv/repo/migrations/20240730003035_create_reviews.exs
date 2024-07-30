defmodule Stressedout.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :product_id, :integer
      add :user_id, :integer
      add :rating, :integer
      add :content, :text

      timestamps()
    end
  end
end
