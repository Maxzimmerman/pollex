defmodule Pollex.Application do
  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Pollex.DynamicSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: Pollex.TaskSuperVisor},
      Pollex.Repo,
      Pollex.NebulexLocalCache,
      Pollex.DatasetInitializer
    ]

    opts = [strategy: :one_for_one, name: Pollex.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
