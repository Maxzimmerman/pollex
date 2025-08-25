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

    interval = :timer.seconds(interval)
    data = load(table)

    schedule_refresh(interval)
    {:ok, %{table: table, columns: columns, interval: interval, name: name, data: data}}
  end

  # Genserver callback to dynamicly update the state by calling the
  # handle cast genserver callback
  @impl true
  def handle_info(:poll, %{table: table, name: name, interval: interval} = state) do
    Task.start(fn ->
      case load(table) do
        {:ok, data} ->
          GenServer.cast(name, {:update, data})
      end
    end)

    schedule_refresh(interval)
    {:noreply, state}
  end

  # Genserver callback to get the data in the state
  @impl true
  def handle_call(:get, _from, %{data: data, columns: columns} = state) do
    data = Enum.map(data, fn t ->
      Map.take(t, columns)
    end)
    {:reply, data, state}
  end

  # Genserver callback to set the data in the state
  @impl true
  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}}
  end

  # Public api function which calls the Genserver callback to fetch the data
  @spec lookup(atom()) :: list(map())
  @impl true
  def lookup(name) do
    GenServer.call(name, :get)
  end
end
