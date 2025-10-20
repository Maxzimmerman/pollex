defmodule Pollex.DatasetInitializer do
  use GenServer
  require Logger

  @delay_ms 2_000

  def start_link(_arge) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Process.send_after(self(), :init_datasets, @delay_ms)
    {:ok, state}
  end

  @impl true
  @spec handle_info(:init_datasets, any()) :: {:noreply, any()}
  def handle_info(:init_datasets, state) do
    datasets = Application.get_env(:pollex, Pollex.Application)[:datasets]
    IO.inspect(datasets)
    IO.puts("Called")
    if is_nil(datasets) do
      Logger.info("[Pollex] No datasets configured.")
      {:noreply, state}
    else
      init()
      {:noreply, state}
    end
  end

  @spec init() :: :ok
  defp init do
    datasets = Application.get_env(:pollex, Pollex.Application)[:datasets]

    case datasets do
      nil ->
        Logger.info("Nothing to start")

      datasets ->
        Enum.each(datasets, fn dataset ->
          {dataset_name, %{cache: cache, source: source, refresh_interval_seconds: rate}} =
            dataset

          case [cache, source] do
            [{GenServerCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
              process_name = dataset_name

              {:ok, _pid} =
                DynamicSupervisor.start_child(
                  Pollex.DynamicSupervisor,
                  {Pollex.EctoGenServerCache,
                   [
                     name: process_name,
                     cache_opts: cache_opts,
                     source_opts: source_opts,
                     refresh_rate: rate
                   ]}
                )

            [{GenServerCacheAdapter, _cache_opts}, {CSVFileSourceAdapter, _source_opts}] ->
              process_name = dataset_name

              {:ok, _pid} =
                DynamicSupervisor.start_child(
                  Pollex.DynamicSupervisor,
                  {Pollex.CSVGenServerCache,
                   [
                     name: process_name,
                     refresh_rate: rate
                   ]}
                )

            [{AlphabeticAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
              names = for name <- ?a..?z, do: <<name>>

              Enum.each(names, fn name ->
                {:ok, _pid} =
                  DynamicSupervisor.start_child(
                    Pollex.DynamicSupervisor,
                    {Pollex.AlphabeticCache,
                     [
                       name: String.to_atom(name),
                       cache_opts: cache_opts,
                       source_opts: source_opts,
                       refresh_rate: rate
                     ]}
                  )
              end)
          end
        end)
    end
  end
end
