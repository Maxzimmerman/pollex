defmodule AlphabeticCache do
  @moduledoc """
  This module acts as a cache for data pulled from a configured database.
  It holds methods to referesh the cache and has functionality to the data up at any time.

  Example usage:

  1. Configure the cache

      config :pollex, Pollex.Application,
        opts: %{
          refresh_interval_seconds: 3,
          source: {AlphabeticCacheAdapter, [table: Pollex.City, repo: Pollex.Repo]},
          cache: {GenServerCacheAdapter, [columns: [:name]]}
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
  use SrcAdapter.AlphabeticAdapter
  use CacheAdapter.GenserverCacheAdapter

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

    schedule_refresh(interval)

    {:ok,
     %{table: table, repo: repo, columns: columns, interval: interval, name: name, data: data}}
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
  def handle_call(:get, _from, %{data: data} = state) do
    {:reply, data, state}
  end

  @impl true
  def handle_cast({:update, new_data}, %{data: existing_data, columns: columns} = state) do
    merged =
      existing_data
      |> Enum.concat(new_data)
      |> Enum.uniq_by(&Map.take(&1, columns))

    {:noreply, %{state | data: merged}}
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
  def lookup(name) do
    GenServer.call(name, :get)
  end
end
