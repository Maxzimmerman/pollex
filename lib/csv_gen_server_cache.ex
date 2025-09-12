defmodule CSVGenServerCache do
  @moduledoc """
  This module acts as a cache for data pulled from a configured file.
  It holds methods to referesh the cache and has functionality to the data up at any time.

  Example usage:

  1. Configure the cache

      config :pollex, Pollex.Application,
        csvs: %{
          countries: %{
            refresh_interval_seconds: 3,
            source: {CSVFileSourceAdapter, []},
            cache: {GenServerCacheAdapter, []}
          }
        }

  You configure a dataset, and an interval.
  The application will start a Genserver process per dataset and run for you.

  2. Get the data

      iex> EctoGenServerCache.lookup(:cities)
      iex>
      [
        %{name: "germany"},
        %{name: "usa"},
        %{name: "australia"},
        %{name: "united kingdom"},
        %{name: "austria"}
      ]
  """

  require Logger
  use SrcAdapter.CSVFileSourceAdapter
  use CacheAdapter.GenserverCacheAdapter

  @spec init(any()) :: {:ok, map()}
  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    interval = Keyword.fetch!(opts, :refresh_rate)

    interval = :timer.seconds(interval)
    {:ok, data} = load(Kernel.to_string(name))

    schedule_refresh(interval)

    {:ok, %{interval: interval, name: name, data: data}}
  end

  @impl true
  def handle_info(:poll, %{name: name, interval: interval} = state) do
    Task.Supervisor.async_nolink(Pollex.TaskSupervisor, fn ->
      case load(Kernel.to_string(name)) do
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
  def handle_cast({:update, new_data}, %{data: existing_data} = state) do
    merged =
      existing_data
      |> Enum.concat(new_data)
      |> Enum.uniq()

    {:noreply, %{state | data: merged}}
  end

  @doc """
  Public api function which calls the Genserver callback to fetch the data

    Example:

      iex> CSVGenServerCache.lookup(:countries)
      iex>
      [
        %{"code" => "de", "name" => "Germany"},
        %{"code" => "us", "name" => "United States of America"},
        %{"code" => "au", "name" => "Australia"},
        %{"code" => "uk", "name" => "United kingdom"},
        %{"code" => "at", "name" => "Austria"}
      ]
  """
  @spec lookup(atom()) :: list(map())
  @impl true
  def lookup(name) do
    GenServer.call(name, :get)
  end
end
