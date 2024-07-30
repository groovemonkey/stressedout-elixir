defmodule Stressedout.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      # add :id, :uuid
      add :name, :string
      add :address, :string

      timestamps()
    end
  end
end
