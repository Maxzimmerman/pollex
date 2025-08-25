defmodule EctoGenServerCache do
  use CacheAdapter.GenserverCacheAdapter
  use SrcAdapter.EctoAdapter

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    IO.puts("Called")
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @spec init(any()) :: {:ok, %{}}
  @impl true
  def init(_init_arg) do
    lookup(:domain, "prefix")
    refresh(:domain)
    {:ok, %{}}
  end

  @spec lookup(atom(), binary()) :: list(map())
  @impl true
  def lookup(_domain, _prefix) do
    [%{}]
  end

  @spec refresh(atom()) :: :ok
  @impl true
  def refresh(_domain) do
    :ok
  end

  @spec schedule_refresh(integer()) :: any()
  @impl true
  def schedule_refresh(interval) do
    Process.send_after(self(), :poll, interval)
  end
end
