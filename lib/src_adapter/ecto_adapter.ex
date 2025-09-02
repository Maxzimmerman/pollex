defmodule SrcAdapter.EctoAdapter do
  @moduledoc """
  This module acts as the data provider it includes functions to
  initally get the data from the db and referesh it
  """
  @callback load(table :: Ecto.Schema.t(), repo :: module(), columns :: list(atom())) ::
              {:ok, list()} | {:error, any()}

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.EctoAdapter
      import Ecto.Query

      @doc """
      Represents the initial data provider
      It calls the handle cast Genserver callback to save the data in the state
      """
      @spec load(Ecto.Schema.t(), module(), list(atom())) :: {:ok, list()} | {:error, any()}
      @impl true
      def load(table, repo, columns) do
        try do
          data =
            repo.all(table)
            |> Enum.map(&Map.take(&1, columns))
            |> Enum.uniq_by(& &1)

          {:ok, data}
        rescue
          e -> {:error, e}
        end
      end

      defoverridable load: 3
    end
  end
end
