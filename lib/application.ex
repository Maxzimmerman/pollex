defmodule Pollex.Application do
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Pollex.DynamicSupervisor, strategy: :one_for_one},
      Pollex.Repo,
      {Task.Supervisor, name: Pollex.TaskSuperVisor}
    ]

    opts = [strategy: :one_for_one, name: Pollex.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)
    init()
    start_alphabetic_system()
    {:ok, sup_pid}
  end

  @spec init() :: :ok
  def init do
    datasets = Application.get_env(:pollex, __MODULE__)[:datasets]

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
      end
    end)
  end

  def start_alphabetic_system do
    names = for name <- ?a..?z, do: <<name>>

    case Application.get_env(:pollex, __MODULE__) do
      opts ->
        %{refresh_interval_seconds: rate, source: source, cache: cache} = opts[:opts]

        Enum.each(names, fn name ->
          case [cache, source] do
            [{GenServerCacheAdapter, cache_opts}, {AlphabeticCacheAdapter, source_opts}] ->
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
          end
        end)
    end
  end
end
