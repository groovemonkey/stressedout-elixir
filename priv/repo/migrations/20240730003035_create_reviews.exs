defmodule Stressedout.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      # add :id, :uuid
      add :product_id, :uuid
      add :user_id, :uuid
      add :rating, :integer
      add :content, :string

      timestamps()
    end
  end
end
