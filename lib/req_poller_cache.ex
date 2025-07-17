defmodule ReqPollerCache do
  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    request = Keyword.fetch!(opts, :request)
    interval = Keyword.get(opts, :interval, :timer.seconds(60))
    name = Keyword.fetch!(opts, :name)

    schedule_poll(interval)
    {:ok, %{request: request, interval: interval, name: name, data: nil}}
  end

  def handle_info(:poll, %{request: req, interval: interval, name: name} = state) do
    IO.inspect(state)
    Task.start(fn ->
      case Req.get(req) do
        {:ok, resp} ->
          IO.puts "SUCCESS"
          GenServer.cast(name, {:update, resp.body})
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

  def get(name), do: GenServer.call(name, :get)

  def handle_call(:get, _from, state), do: {:reply, state.data, state}

  defp schedule_poll(interval), do: Process.send_after(self(), :poll, interval)
end
