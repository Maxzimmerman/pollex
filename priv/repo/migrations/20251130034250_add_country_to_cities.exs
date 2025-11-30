defmodule Pollex.Repo.Migrations.AddCountryToCities do
  use Ecto.Migration

  def change do
    alter table(:cities) do
      add :country, :string
    end
  end
end
