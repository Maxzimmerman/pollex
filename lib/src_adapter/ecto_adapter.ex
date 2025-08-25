defmodule SrcAdapter.EctoAdapter do
  @moduledoc """
  This module acts as the data provider it includes functions to
  initally get the data from the db and referesh it
  """
  alias Pollex.Repo
  @callback load(table :: Keyword.t()) :: [map()]
  @callback schedule_refresh(interval :: integer()) :: any()

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.EctoAdapter
      import Ecto.Query

      alias Pollex.Repo

      @doc """
      Represents the initial data provider
      It calls the handle cast Genserver callback to save the data in the state
      """
      @spec load(Keyword.t()) :: {:ok, list()}
      @impl true
      def load(table) do
        query =
          from e in table,
            select: e.name

        data = Repo.all(query)
        {:ok, data}
      end

      @spec schedule_refresh(integer()) :: any()
      @impl true
      def schedule_refresh(interval) do
        IO.puts("called scheduler")
        Process.send_after(self(), :poll, interval)
      end

      defoverridable load: 1, schedule_refresh: 1
    end
  end
end
