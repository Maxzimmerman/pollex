defmodule Pollex.NebulexCache do
  require Logger

  use Pollex.SrcAdapter.EctoAdapter
  use Pollex.CacheAdapter.GenserverCacheAdapter
  alias Pollex.NebulexLocalCache, as: Cache

  @impl true
  def init(opts) do
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = Keyword.fetch!(opts, :refresh_rate)
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]

    interval = :timer.seconds(interval)
    {:ok, data} = load(table, repo, columns)

    transformed_data = transform_to_nebulex_format(data)

    Cache.put_all(transformed_data)

    schedule_refresh(interval)

    {:ok, %{table: table, repo: repo, columns: columns, interval: interval}}
  end

  @impl true
  def handle_info(:poll, state) do
    %{table: table, repo: repo, columns: columns, interval: interval} = state

    Task.Supervisor.async_nolink(Pollex.TaskSuperVisor, fn ->
      case load(table, repo, columns) do
        {:ok, data} ->
          GenServer.cast(self(), {:update, data})

        {:error, reason} ->
          Logger.error("Failed to refresh data: #{inspect(reason)}")
      end
    end)
    |> Task.ignore()

    schedule_refresh(interval)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:update, data}, state) do
    Cache.put_all(data)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    keys = Cache.all()
    data = Cache.get_all(keys)
    {:reply, data, state}
  end

  def lookup(name), do: GenServer.call(name, :get)

  def transform_to_nebulex_format(data) do
    Map.new(data, fn entry ->
      case Map.to_list(entry) do
        [{_key, value} | _] ->
          {to_string(value), entry}

        [] ->
          {nil, entry}
      end
    end)
    |> Map.drop([nil])
  end
end
