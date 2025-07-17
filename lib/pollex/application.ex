defmodule Pollex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ReqPollerCache, [request: "https://google.com", interval: :timer.seconds(30), name: ReqPollerCache]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pollex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
