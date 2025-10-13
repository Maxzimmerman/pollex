defmodule CSVGenServerCacheTest do
  use ExUnit.Case, async: false

  alias Pollex.CSVGenServerCache

  setup do
    name = :countries
    source_opts = []
    cache_opts = []
    interval = 1

    pid =
      start_supervised!(
        {CSVGenServerCache,
         [
           name: name,
           source_opts: source_opts,
           cache_opts: cache_opts,
           refresh_rate: interval
         ]}
      )

    {:ok, name: name, pid: pid}
  end

  test "state updates after poll", %{name: name} do
    Process.sleep(100)

    data = CSVGenServerCache.lookup(name)
    assert Enum.any?(data, &(&1["name"] == "Germany"))
  end

  test "initial state loads from DB", %{name: name} do
    Process.sleep(100)
    data = CSVGenServerCache.lookup(name)
    assert Enum.any?(data, &(&1["name"] == "Germany"))
    assert Enum.any?(data, &(&1["name"] == "United States of America"))
  end
end
