defmodule Pollex.Application do
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Pollex.DynamicSupervisor, strategy: :one_for_one},
      Pollex.Repo
    ]

    opts = [strategy: :one_for_one, name: Pollex.Supervisor]
    {:ok, sup_pid} = Supervisor.start_link(children, opts)

    init()

    {:ok, sup_pid}
  end

  @spec init() :: :ok
  defp init do
    datasets = Application.get_env(:pollex, __MODULE__)[:datasets]

    Enum.each(datasets, fn dataset ->
      {dataset_name, %{cache: cache, source: source, refresh_interval_seconds: rate}} = dataset

      case [cache, source] do
        [{GenServerCacheAdapter, cache_opts}, {EctoSourceAdapter, source_opts}] ->
          process_name = dataset_name
          IO.puts(process_name)

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
end
