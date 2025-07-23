defmodule ReqPollerCache do
  @moduledoc """
    Provides methods for fetching and recieving data.
    To use it just add the following to your applicaion.ex it needs three inputs: request, interval and name

      {ReqPollerCache, [request: "https://google.com", interval: :timer.seconds(30), name: ReqPollerCache]}
  """

  use GenServer

  @spec start_link(keyword()) :: :ignore | {:error, any()} | {:ok, pid()}
  @doc """
    Starts the process with a given name
  """
  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
    Initalizes the process with a default state given in opts
  """
  def init(opts) do
    request = Keyword.fetch!(opts, :request)
    interval = Keyword.get(opts, :interval, :timer.seconds(60))
    name = Keyword.fetch!(opts, :name)

    schedule_poll(interval)
    {:ok, %{request: request, interval: interval, name: name, data: nil}}
  end

  def handle_info(:poll, %{request: req, interval: interval, name: name} = state) do
    Task.start(fn ->
      case Req.get(req) do
        {:ok, resp} ->
          GenServer.cast(name, {:update, resp.body})
        _ ->
          :noop
        Req.get(req)
      end
    end)

    schedule_poll(interval)
    {:noreply, state}
  end

  def handle_cast({:update, data}, state) do
    {:noreply, %{state | data: data}}
  end

  @doc """
    Gets the lates fetched data.

      iex> cached = ReqPollerCache.get(ReqPollerCache)
      iex> cached
      nil
  """
  def get(name), do: GenServer.call(name, :get)

  def handle_call(:get, _from, state), do: {:reply, state.data, state}

  defp schedule_poll(interval), do: Process.send_after(self(), :poll, interval)
end
