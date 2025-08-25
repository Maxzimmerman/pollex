defmodule CacheAdapter.GenserverCacheAdapter do
  @moduledoc """
  This module acts as the open api, you can look the data up and specify the columns you wanna get
  """
  @callback lookup(domain :: atom(), prefix :: binary()) :: list(map())

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour CacheAdapter.GenserverCacheAdapter

      @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
      def start_link(opts) do
        name = Keyword.fetch!(opts, :name)
        GenServer.start_link(__MODULE__, opts, name: name)
      end

      @doc """
      Represents the public api to fetch the data
      """
      @spec lookup(atom(), binary()) :: list(map())
      def lookup(_domain, _prefix) do
        raise "lookup/1 must be implemented"
      end

      defoverridable lookup: 2
    end
  end
end
