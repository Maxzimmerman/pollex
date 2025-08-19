defmodule CacheAdapter.GenserverCacheAdapter do
  @callback lookup(domain :: atom(), prefix :: binary()) :: list(map())
  @callback refresh(domain :: atom()) :: :ok

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour CacheAdapter.GenserverCacheAdapter

      @spec lookup(atom(), binary()) :: list(map())
      def lookup(_domain, _prefix) do
        raise "lookup/2 must be implemented"
      end

      @spec refresh(atom()) :: :ok
      def refresh(_domain) do
        raise "refresh/1 must be implemented"
      end

      defoverridable lookup: 2, refresh: 1
    end
  end
end
