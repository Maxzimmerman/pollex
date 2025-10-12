defmodule Pollex.Application do
  require Logger
  alias Pollex.SrcAdapter.AlphabeticAdapter
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Pollex.DynamicSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Pollex.TaskSuperVisor}
    ]

    opts = [strategy: :one_for_one, name: Pollex.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)
    init()

    {:ok, pid}
  end

  @spec init() :: :ok
  def init do
    datasets = Application.get_env(:pollex, __MODULE__)[:datasets]

    case datasets do
      nil ->
        Logger.info("Nothing to start")

      datasets ->
      Enum.each(datasets, fn dataset ->
        {dataset_name, %{cache: cache, source: source, refresh_interval_seconds: rate}} = dataset

        case [cache, source] do
          [{GenServerCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
            process_name = dataset_name

            {:ok, _pid} =
              DynamicSupervisor.start_child(
                Pollex.DynamicSupervisor,
                {EctoGenServerCache,
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
                {CSVGenServerCache,
                [
                  name: process_name,
                  refresh_rate: rate
                ]}
              )

          [{AlphabeticAdapter, cache_opts}, {GenServerCacheAdapter, source_opts}] ->
            names = for name <- ?a..?z, do: <<name>>
            IO.inspect(names)
            Enum.each(names, fn name ->
              {:ok, _pid} =
                DynamicSupervisor.start_child(
                  Pollex.DynamicSupervisor,
                  {AlphabeticCache,
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
