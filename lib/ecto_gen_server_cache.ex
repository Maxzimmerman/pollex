defmodule EctoGenServerCache do
  use SrcAdapter.EctoAdapter
  use CacheAdapter.GenserverCacheAdapter

  @spec init(any()) :: {:ok, map()}
  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    table = Keyword.fetch!(opts, :source_opts)[:table]
    interval = Keyword.fetch!(opts, :refresh_rate)
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]

    data = load(table)
    IO.inspect(data)
    {:ok, %{table: table, columns: columns, interval: interval, name: name, data: data}}
  end

  # Genserver callback to get the data in the state
  @impl true
  def handle_call(:get, _from, state), do: {:reply, state.data, state}

  # Genserver callback to set the data in the state
  @impl true
  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}}
  end

  @doc """
  Represents the public api to fetch the data
  """
  @spec lookup(atom(), binary()) :: list(map())
  @impl true
  def lookup(_domain, _prefix) do
    [%{}]
  end
end
