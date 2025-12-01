defmodule Pollex.AlphabeticNebulexCache do
  @moduledoc """
  This module acts as a cache for data pulled from a configured database.
  It holds methods to referesh the cache and has functionality to the data up at any time.
  This cache strategy implements the Nebulex cache to support more advanced cache runtime options.
  Basically this cache creates

  Example usage:

  1. Configure the cache

      config :pollex, Pollex.Application,
        datasets: %{
          unlocodes: %{
            refresh_interval_seconds: 6,
            cache: {NebulexCacheAdapter, [columns: [:name]]},
            source: {AlphabeticAdapter, [table: Mosaic.City, repo: Pollex.Repo]}
          }
        }

  You configure a dataset, an interval, a table, repo and the columns you want to fetch.
  The application will start a Genserver process per letter in the alphabet holding the data starting with that letter and run for you.

  2. Get the data

      iex> AlphabeticNebulexCache.lookup(:a)
      iex>
      [
        %{name: "australia"},
        %{name: "austria"}
      ]
  """

  require Logger
  use Pollex.SrcAdapter.AlphabeticAdapter
  use Pollex.CacheAdapter.GenServerCacheAdapter

  alias Pollex.Helpers.Nebulex, as: NebulexHelpers
  alias Pollex.Helpers.DynamicCache

  @spec init(any()) :: {:ok, map()}
  @impl true
  def init(opts) do
    genserver_name = Keyword.fetch!(opts, :name)
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = :timer.seconds(Keyword.fetch!(opts, :refresh_rate))
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]
    cache_opts = Keyword.fetch!(opts, :cache_runtime_opts)
    _query_column = Keyword.fetch!(opts, :query_column)

    # Load initial data
    {:ok, data} = load(table, repo, columns, Atom.to_string(genserver_name))

    transformed_data = NebulexHelpers.transform_to_nebulex_format(data)

    # Build a unique dynamic cache module
    module_suffix =
      genserver_name
      |> Atom.to_string()
      |> String.upcase()

    dynamic_cache_module =
      DynamicCache.build_local_cache(:"Cache#{module_suffix}", cache_opts)

    # Start the local cache instance
    {:ok, cache_pid} = dynamic_cache_module.start_link(name: dynamic_cache_module)
    Process.unlink(cache_pid)

    dynamic_cache_module.put_all(transformed_data)

    schedule_refresh(interval)

    {:ok,
     %{
       table: table,
       repo: repo,
       columns: columns,
       interval: interval,
       genserver_name: genserver_name,
       cache_mod: dynamic_cache_module
     }}
  end

  @impl true
  def handle_info(
        :poll,
        %{
          table: table,
          columns: columns,
          repo: repo,
          genserver_name: genserver_name,
          interval: interval
        } = state
      ) do
    Task.Supervisor.async_nolink(Pollex.TaskSuperVisor, fn ->
      case load(table, repo, columns, Atom.to_string(genserver_name)) do
        {:ok, data} ->
          GenServer.cast(genserver_name, {:update, data})

        {:error, reason} ->
          Logger.error("Failed to load data: #{inspect(reason)}")
      end
    end)
    |> Task.ignore()

    schedule_refresh(interval)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, %{cache_mod: cache_mod} = state) do
    data =
      cache_mod.stream()
      |> Enum.reduce(%{}, fn key, acc ->
        case cache_mod.get(key) do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end)

    {:reply, data, state}
  end

  @impl true
  def handle_cast({:update, new_data}, %{cache_mod: cache_mod} = state) do
    transformed = NebulexHelpers.transform_to_nebulex_format(new_data)
    cache_mod.put_all(transformed)
    {:noreply, state}
  end

  @doc """
  Public api function which calls the Genserver callback to fetch the data

    Example:

      iex> AlphabeticNebulexCache.lookup(:a)
      iex>
      [
        %{name: "australia"},
        %{name: "austria"}
      ]
  """
  @spec lookup(atom()) :: list(map())
  @impl true
  def lookup(name), do: GenServer.call(name, :get)
end
