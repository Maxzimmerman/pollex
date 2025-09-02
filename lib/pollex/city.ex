defmodule Pollex.City do
  @moduledoc """
  A City is contained in a state within a county
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:name, :string, autogenerate: false}
  schema "cities" do
  end

  @doc false
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
