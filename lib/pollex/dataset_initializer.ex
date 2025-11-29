defmodule Pollex.DatasetInitializer do
  use GenServer
  require Logger

  @retry_ms 2_000
  @max_retries 10

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    Process.send_after(self(), :init_datasets, @retry_ms)
    {:ok, %{tries: 0}}
  end

  @impl true
  def handle_info(:init_datasets, %{tries: tries} = state) do
    config = Application.get_env(:pollex, Pollex.Application)

    datasets = Keyword.get(config || [], :datasets)

    new_state = %{state | tries: tries + 1}

    if is_nil(datasets) or map_size(datasets) == 0 do
      Logger.info("[Pollex] No datasets configured — retrying...")
      schedule_retry(new_state.tries)
      {:noreply, new_state}
    else
      if repo_ready?(datasets) do
        Logger.info("[Pollex] Starting datasets...")
        start_datasets(datasets)
        {:noreply, new_state}
      else
        Logger.info("[Pollex] Repo is not ready yet")
        schedule_retry(new_state.tries)
        {:noreply, new_state}
      end
    end
  end

  defp schedule_retry(tries) when @max_retries > tries do
    Process.send_after(self(), :init_datasets, @retry_ms)
  end

  defp schedule_retry(tries) do
    Logger.warning("[Pollex] Reached max retries (#{tries}) — stopping retry loop")
    :ok
  end

  defp repo_ready?(datasets) do
    Enum.all?(datasets, fn {_name, %{source: {_adapter, opts}}} ->
      case Keyword.get(opts, :repo) do
        nil -> true
        repo -> Code.ensure_loaded?(repo) and Process.whereis(repo) != nil
      end
    end)
  end

  defp start_datasets(datasets) do
    Enum.each(datasets, fn {dataset_name,
                            %{cache: cache, source: source, refresh_interval_seconds: rate}} ->
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

        [{GenServerCacheAdapter, cache_opts}, {AlphabeticAdapter, source_opts}] ->
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

        [{NebulexCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
          DynamicSupervisor.start_child(
            Pollex.DynamicSupervisor,
            {Pollex.NebulexCache,
             [
               name: dataset_name,
               cache_opts: cache_opts,
               source_opts: source_opts,
               refresh_rate: rate
             ]}
          )

        [{NebulexCacheAdapter, cache_opts}, {AlphabeticAdapter, source_opts}] ->
          DynamicSupervisor.start_child(
            Pollex.DynamicSupervisor,
            {Pollex.NebulexCache,
             [
               name: dataset_name,
               cache_opts: cache_opts,
               source_opts: source_opts,
               refresh_rate: rate
             ]}
          )
      end
    end)
  end
end
