defmodule Pollex.AlphabeticNebulexCache do
  @moduledoc """
  This module acts as a cache for data pulled from a configured database.
  It holds methods to referesh the cache and has functionality to the data up at any time.

  Example usage:

  1. Configure the cache

      config :pollex, Pollex.Application,
        datasets: %{
          unlocodes: %{
            refresh_interval_seconds: 6,
            cache: {AlphabeticAdapter, [columns: [:name]]},
            source: {EctoSourceAdapter, [table: Mosaic.City, repo: Pollex.Repo]}
          }
        }

  You configure a dataset, an interval, a table, repo and the columns you want to fetch.
  The application will start a Genserver process per letter in the alphabet holding the data starting with that letter and run for you.

  2. Get the data

      iex> AlphabeticCache.lookup(:a)
      iex>
      [
        %{name: "australia"},
        %{name: "austria"}
      ]
  """

  require Logger
  use Pollex.SrcAdapter.AlphabeticAdapter
  use Pollex.CacheAdapter.GenserverCacheAdapter
  alias Pollex.NebulexLocalCache, as: Cache

  @spec init(any()) :: {:ok, map()}
  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = Keyword.fetch!(opts, :refresh_rate)
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]
    cache_opts = Keyword.get(opts, :cache_runtime_opts, [])

    interval = :timer.seconds(interval)
    {:ok, data} = load(table, repo, columns, Kernel.to_string(name))

    transformed_data = transform_to_nebulex_format(data)

    sub_cache_name = :"cache_#{inspect(self())}"
    IO.inspect(sub_cache_name)

    {:ok, cache_pid} =
      Cache.start_link(
        Keyword.merge(
          [name: sub_cache_name],
          cache_opts
        )
      )

    Process.unlink(cache_pid)

    Cache.put_all(transformed_data, name: sub_cache_name)

    schedule_refresh(interval)

    {:ok,
     %{
      table: table,
      repo: repo,
      columns: columns,
      interval: interval,
      name: name,
      data: data,
      sub_cache_name: sub_cache_name
      }}
  end

  @impl true
  def handle_info(
        :poll,
        %{table: table, columns: columns, repo: repo, name: name, interval: interval} = state
      ) do
    Task.Supervisor.async_nolink(Pollex.TaskSuperVisor, fn ->
      case load(table, repo, columns, Kernel.to_string(name)) do
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

  @impl true
  def handle_cast({:update, new_data}, %{sub_cache_name: name} = state) do
    transformed_data = transform_to_nebulex_format(new_data)
    Cache.put_all(transformed_data, name: name)
    {:noreply, state}
  end

  @doc """
  Public api function which calls the Genserver callback to fetch the data

    Example:

      iex> AlphabeticCache.lookup(:a)
      iex>
      [
        %{name: "australia"},
        %{name: "austria"}
      ]
  """
  @spec lookup(atom()) :: list(map())
  @impl true
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
