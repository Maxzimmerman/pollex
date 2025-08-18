defmodule CacheAdapter do
  @callback lookup(domain :: atom(), prefix :: binary()) :: list(map())
  @callback refresh(domain :: atom()) :: :ok

  defmacro __using__(_opts) do
    quote do
      @behaviour CacheAdapter

      def lookup(_domain, _prefix) do
        raise "lookup/2 must be implemented"
      end

      def refresh(_domain) do
        raise "refresh/1 must be implemented"
      end

      defoverridable lookup: 2, refresh: 1
    end
  end
end
