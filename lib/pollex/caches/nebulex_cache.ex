defmodule Pollex.NebulexCache do
  @moduledoc """
  This module acts as a cache for data pulled from a configured file.
  It holds methods to referesh the cache and has functionality to the data up at any time.

  Example usage:

  1. Configure the cache

      config :pollex, Pollex.Application,
        datasets: %{
          cities: %{
            refresh_interval_seconds: 6,
            cache: {NebulexCacheAdapter, [columns: [:name]]},
            source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
            cache_runtime_opts: [
              gc_interval: :timer.hours(12),
              max_size: 1_000_000,
              allocated_memory: 2_000_000_000,
              gc_cleanup_min_timeout: :timer.seconds(10),
              gc_cleanup_max_timeout: :timer.minutes(10)
            ]
          }
        }

  You configure a dataset, and an interval.
  The application will start a Genserver process per dataset and run for you.

  2. Get the data

      iex> NebulexCache.lookup(:cities)
      iex>
      %{
        "australia" => "australia",
        "austria" => "austria",
        "azerbaijan" => "azerbaijan",
        "germany" => "germany",
        "russia" => "russia",
        "united kingdom" => "united kingdom",
        "usa" => "usa"
      }
  """

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
    cache_opts = Keyword.get(opts, :cache_runtime_opts, [])

    interval = :timer.seconds(interval)
    {:ok, data} = load(table, repo, columns)

    transformed_data = transform_to_nebulex_format(data)

    # Start internall cache and put in the data
    sub_cache_name = :"cache_#{inspect(self())}"

    {:ok, cache_pid} =
      Cache.start_link(
        Keyword.merge(
          [name: sub_cache_name],
          cache_opts
        )
      )

    # unlink the process so this process will not crash when the subcache crashes
    Process.unlink(cache_pid)

    Cache.put_all(transformed_data, name: sub_cache_name)

    schedule_refresh(interval)

    {:ok,
     %{
       table: table,
       repo: repo,
       columns: columns,
       interval: interval,
       sub_cache_name: sub_cache_name
     }}
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
  def handle_cast({:update, data}, %{sub_cache_name: name} = state) do
    transformed_data = transform_to_nebulex_format(data)
    Cache.put_all(transformed_data, name: name)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, %{sub_cache_name: name} = state) do
    data =
      Cache.stream(nil, name: name)
      |> Enum.map(fn
        {k, v} -> {k, v}
        other -> {other, other}
      end)
      |> Map.new()

    {:reply, data, state}
  end

  @doc """
  Public api function which calls the Genserver callback to fetch the data

    Example:

      iex> NebulexCache.lookup(:cities)
      iex>
      %{
        "australia" => "australia",
        "austria" => "austria",
        "azerbaijan" => "azerbaijan",
        "germany" => "germany",
        "russia" => "russia",
        "united kingdom" => "united kingdom",
        "usa" => "usa"
      }
  """
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
