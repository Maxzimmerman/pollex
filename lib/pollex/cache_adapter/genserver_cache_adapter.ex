defmodule Pollex.CacheAdapter.GenserverCacheAdapter do
  alias Pollex.CacheAdapter.GenserverCacheAdapter

  @moduledoc """
  This module acts as the open api, you can look the data up and specify the columns you wanna get
  """
  @callback lookup(name :: atom()) :: list(map())
  @callback schedule_refresh(interval :: integer()) :: any()

  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour GenserverCacheAdapter

      @doc """
      This is the first function called when the Genserver process is initialised
      It configures a given name so we can have many Process of the same type
      """
      @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
      def start_link(opts) do
        name = Keyword.fetch!(opts, :name)
        GenServer.start_link(__MODULE__, opts, name: name)
      end

      @doc """
      Represents the public api to fetch the data
      """
      @spec lookup(atom()) :: list(map())
      def lookup(_name) do
        raise "lookup/1 must be implemented"
      end

      @doc """
      Represents the loop
      It sends the :poll message after a configured interval
      """
      @spec schedule_refresh(integer()) :: any()
      @impl true
      def schedule_refresh(interval) do
        Process.send_after(self(), :poll, interval)
      end

      defoverridable lookup: 1, schedule_refresh: 1
    end
  end
end
