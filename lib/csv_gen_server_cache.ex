defmodule CSVGenServerCache do
  require Logger
  use SrcAdapter.CSVFileSourceAdapter
  use CacheAdapter.GenserverCacheAdapter

  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = Keyword.fetch!(opts, :refresh_rate)
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]

    interval = :timer.seconds(interval)
    {:ok, data} = load("")

    schedule_refresh(interval)

    {:ok,
      %{table: table, repo: repo, columns: columns, interval: interval, name: name, data: data}}
  end

  def handle_info(:poll, %{name: name, interval: interval} = state) do
    Task.Supervisor.async_nolink(Pollex.TaskSupervisor, fn ->
      case load("") do
        {:ok, data} ->
          GenServer.cast(name, {:update, data})

        {:error, reason} ->
          Logger.error("Failed to load data: #{inspect(reason)}")
      end
    end)
    |> Task.ignore()

    schedule_refresh(interval)
    {:noreply, state}
  end

  def handle_call(:get, _from, %{data: data} = state) do
    {:reply, data, state}
  end

  def handle_cast({:update, new_data}, %{data: existing_data, columns: columns} = state) do
    merged =
      existing_data
      |> Enum.concat(new_data)
      |> Enum.uniq_by(&Map.take(&1, columns))

    {:noreply, %{state | data: merged}}
  end

  def lookup(name) do
    GenServer.call(name, :get)
  end
end
