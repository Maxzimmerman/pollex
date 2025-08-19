defmodule ReferenceCache do
  def init do
    datasets = Application.get_env(:pollex, __MODULE__)[:datasets]
    pids =
      Enum.map(datasets, fn dataset ->
        {:ok, pid} = GenServer.start_link(Cache, {})
        IO.inspect(dataset)
        pid
      end)
    IO.inspect(pids)
    pids
  end
end
