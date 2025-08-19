defmodule Cache do
  use CacheAdapter.GenserverCacheAdapter

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    IO.puts "Called start link"
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @spec init(any()) :: {:ok, %{}}
  def init(init_arg) do
    IO.puts "Called init"
    IO.inspect(init_arg)

    lookup(:domain, "prefix")
    refresh(:domain)
    {:ok, %{}}
  end

  @spec lookup(atom(), binary()) :: list(map())
  @impl true
  def lookup(domain, prefix) do
    IO.puts("Called lookup")
    IO.puts(domain)
    IO.puts(prefix)
    [%{}]
  end

  @spec refresh(atom()) :: :ok
  @impl true
  def refresh(domain) do
    IO.puts("Called refresh")
    IO.puts(domain)
    :ok
  end
end
