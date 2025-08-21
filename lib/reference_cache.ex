defmodule ReferenceCache do
  @spec init() :: list()
  def init do
    datasets = Application.get_env(:pollex, __MODULE__)[:datasets]
    pids =
      Enum.map(datasets, fn dataset ->
        {_dataset_name, %{cache: cache, source: source, refresh_interval_seconds: rate}} = dataset
        case [cache, source] do
          [{GenServerCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
            process_name = Ecto.UUID.generate() |> String.to_atom()
            {:ok, pid} = Cache.start_link(name: process_name, cache_opts: cache_opts, source_opts: source_opts, refresh_rate: rate)
            pid
          end
      end)
    pids
  end
end
