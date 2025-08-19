defmodule Pollex.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ReqPollerCache, [request: "https://google.com", interval: :timer.seconds(30), name: :t]}
    ]

    opts = [strategy: :one_for_one, name: Pollex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
