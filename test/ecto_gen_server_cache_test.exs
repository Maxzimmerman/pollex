defmodule EctoGenServerCacheTest do
  use ExUnit.Case, async: false

  alias Pollex.{Repo, City}
  alias EctoGenServerCache

  setup do
    # Insert some test data
    Repo.insert!(%City{name: "germany"})
    Repo.insert!(%City{name: "usa"})

    # Setup GenServer
    name = :"poller_test_#{System.unique_integer([:positive])}"
    source_opts = [table: City, repo: Repo]
    cache_opts = [columns: [:name]]
    interval = 1

    pid =
      start_supervised!(
        {EctoGenServerCache,
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

    data = EctoGenServerCache.lookup(name)
    assert Enum.any?(data, &(&1.name == "germany"))
  end

  test "initial state loads from DB", %{name: name} do
    Process.sleep(100)
    data = EctoGenServerCache.lookup(name)
    assert Enum.any?(data, &(&1.name == "germany"))
    assert Enum.any?(data, &(&1.name == "usa"))
  end
end
