defmodule ReqPollerCache do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    request = Keyword.fetch!(opts, :request)
    interval = Keyword.get(opts, :interval, :timer.seconds(60))

    schedule_poll(interval)
    {:ok, %{request: request, interval: interval, data: nil}}
  end

  def handle_info(:poll, %{request: req, interval: interval} = state) do
    IO.inspect(state)
    Task.start(fn ->
      case Req.get(req) do
        {:ok, resp} ->
          IO.puts "SUCCESS"
          GenServer.cast(__MODULE__, {:update, resp.body})
        _ ->
          IO.puts "FAIL"
          :noop
    end
  end)

  schedule_poll(interval)
    {:noreply, state}
  end

  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}}
  end

  def get(), do: GenServer.call(__MODULE__, :get)

  def handle_call(:get, _from, state), do: {:reply, state.data, state}

  defp schedule_poll(interval), do: Process.send_after(self(), :poll, interval)
end
