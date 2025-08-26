defmodule SrcAdapter.EctoAdapter do
  @moduledoc """
  This module acts as the data provider it includes functions to
  initally get the data from the db and referesh it
  """
  @callback load(table :: Ecto.Schema.t(), repo :: module()) :: {:ok, list()}
  @callback schedule_refresh(interval :: integer()) :: any()

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.EctoAdapter
      import Ecto.Query

      @doc """
      Represents the initial data provider
      It calls the handle cast Genserver callback to save the data in the state
      """
      @spec load(Ecto.Schema.t(), module()) :: {:ok, list()}
      @impl true
      # TODO table should be the schema module not a string
      def load(table, repo) do
        data = repo.all(table)
        {:ok, data}
      end

      @spec schedule_refresh(integer()) :: any()
      @impl true
      def schedule_refresh(interval) do
        Process.send_after(self(), :poll, interval)
      end

      defoverridable load: 2, schedule_refresh: 1
    end
  end
end
