defmodule Pollex.Repo.Migrations.CreateCities do
  use Ecto.Migration

  def change do
    create table(:cities, primary_key: false) do
      add :name, :string, primary_key: true
    end
  end
end
