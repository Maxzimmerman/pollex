defmodule Pollex.DatasetInitializer do
  use GenServer
  require Logger

  @retry_ms 2_000

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Process.send_after(self(), :init_datasets, @retry_ms)
    {:ok, state}
  end

  @impl true
  def handle_info(:init_datasets, state) do
    case Application.get_env(:pollex, Pollex.Application) do
      nil ->
        Logger.info("[Pollex] No :pollex, Pollex.Application config found — retrying...")
        schedule_retry()
        {:noreply, state}

      %{datasets: datasets} when map_size(datasets) > 0 ->
        case repo_ready?(datasets) do
          true ->
            Logger.info("[Pollex] Starting datasets...")
            start_datasets(datasets)
            {:noreply, state}

          false ->
            Logger.info("[Pollex] Repo not ready — retrying in #{@retry_ms}ms")
            schedule_retry()
            {:noreply, state}
        end

      _ ->
        Logger.info("[Pollex] No datasets configured.")
        {:noreply, state}
    end
  end

  defp schedule_retry, do: Process.send_after(self(), :init_datasets, @retry_ms)

  defp repo_ready?(datasets) do
    Enum.all?(datasets, fn {_name, %{source: {_adapter, opts}}} ->
      case Keyword.get(opts, :repo) do
        nil -> true
        repo -> Code.ensure_loaded?(repo) and Process.whereis(repo) != nil
      end
    end)
  end

  defp start_datasets(datasets) do
    Enum.each(datasets, fn {dataset_name, %{cache: cache, source: source, refresh_interval_seconds: rate}} ->
      case [cache, source] do
        [{GenServerCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
          DynamicSupervisor.start_child(
            Pollex.DynamicSupervisor,
            {Pollex.EctoGenServerCache,
             [
               name: dataset_name,
               cache_opts: cache_opts,
               source_opts: source_opts,
               refresh_rate: rate
             ]}
          )

        [{AlphabeticAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
          for name <- ?a..?z do
            DynamicSupervisor.start_child(
              Pollex.DynamicSupervisor,
              {Pollex.AlphabeticCache,
               [
                 name: String.to_atom(<<name>>),
                 cache_opts: cache_opts,
                 source_opts: source_opts,
                 refresh_rate: rate
               ]}
            )
          end

        [{GenServerCacheAdapter, _cache_opts}, {CSVFileSourceAdapter, _source_opts}] ->
          DynamicSupervisor.start_child(
            Pollex.DynamicSupervisor,
            {Pollex.CSVGenServerCache,
             [
               name: dataset_name,
               refresh_rate: rate
             ]}
          )
      end
    end)
  end
end
