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

  @spec init(any()) :: {:ok, map()}
  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    table = Keyword.fetch!(opts, :source_opts)[:table]
    repo = Keyword.fetch!(opts, :source_opts)[:repo]
    interval = Keyword.fetch!(opts, :refresh_rate)
    columns = Keyword.fetch!(opts, :cache_opts)[:columns]

    interval = :timer.seconds(interval)
    {:ok, data} = load(table, repo, columns, Kernel.to_string(name))

    transformed_data = NebulexHelpers.transform_to_nebulex_format(data)

    # IMPORTANT — build per-letter cache module
    cache_module = Pollex.DynamicCacheBuilder.build(name)

    # IMPORTANT — use dynamic module, not Cache
    cache_module.put_all(transformed_data)

    schedule_refresh(interval)

    {:ok,
    %{
      table: table,
      repo: repo,
      columns: columns,
      interval: interval,
      name: name,
      data: data,
      cache_module: cache_module
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
  def handle_call(:get, _from, %{cache_module: cache} = state) do
    data =
      cache.stream()
      |> Enum.map(fn
        {k, {:value, v}} -> {to_string(k), v}
        {k, v} -> {to_string(k), v}
      end)
      |> Map.new()

    {:reply, data, state}
  end

  @impl true
  def handle_cast({:update, new_data}, %{cache_module: cache} = state) do
    transformed_data = NebulexHelpers.transform_to_nebulex_format(new_data)
    cache.put_all(transformed_data)
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
