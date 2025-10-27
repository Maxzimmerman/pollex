defmodule Pollex.NebulexCache do
  require Logger

  use Pollex.SrcAdapter.EctoAdapter
  use Pollex.CacheAdapter.GenserverCacheAdapter
  alias Pollex.NebulexLocalCache, as: Cache

  @impl true
  def init(opts) do
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = :timer.seconds(Keyword.fetch!(opts, :refresh_rate))
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]

    {:ok, data} = load(table, repo, columns)
    Cache.put_all(data)
    schedule_refresh(interval)

    IO.puts("{{{{{{{{{MADE IT}}}}}}}}}")

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
end
