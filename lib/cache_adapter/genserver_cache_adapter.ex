defmodule CacheAdapter.GenserverCacheAdapter do
  @callback lookup(domain :: atom(), prefix :: binary()) :: list(map())
  @callback refresh(domain :: atom()) :: :ok
  @callback schedule_refresh(interval :: integer()) :: any()

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      use GenServer
      @behaviour CacheAdapter.GenserverCacheAdapter

      @spec lookup(atom(), binary()) :: list(map())
      def lookup(_domain, _prefix) do
        raise "lookup/2 must be implemented"
      end

      @spec refresh(atom()) :: :ok
      def refresh(_domain) do
        raise "refresh/1 must be implemented"
      end

      @spec schedule_refresh(integer()) :: any()
      def schedule_refresh(_intervall) do
        raise "schedule_refresh/0 must be implemented"
      end

      defoverridable lookup: 2, refresh: 1, schedule_refresh: 1
    end
  end
end
