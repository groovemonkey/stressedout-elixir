defmodule Stressedout.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      # add :id, :uuid
      add :name, :string
      add :description, :string
      add :price, :float

      timestamps()
    end
  end
end
