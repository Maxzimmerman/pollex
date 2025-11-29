defmodule AlphabeticNebulexCacheTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  alias Pollex.{Repo, City}
  alias Pollex.AlphabeticNebulexCache

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    # Insert some test data
    Repo.insert!(%City{name: "germany"})
    Repo.insert!(%City{name: "usa"})

    # Setup GenServer
    name = :"poller_test_#{System.unique_integer([:positive])}"
    source_opts = [table: City, repo: Repo]
    cache_opts = [columns: [:name]]
    interval = 1

    sub_cache_opts = [
      gc_interval: :timer.hours(12),
      max_size: 1_000_000,
      allocated_memory: 2_000_000_000,
      gc_cleanup_min_timeout: :timer.seconds(10),
      gc_cleanup_max_timeout: :timer.minutes(10)
    ]

    pid =
      start_supervised!(
        {AlphabeticNebulexCache,
         [
           name: name,
           source_opts: source_opts,
           cache_opts: cache_opts,
           refresh_rate: interval,
           cache_runtime_opts: sub_cache_opts
         ]}
      )

    {:ok, name: name, pid: pid}
  end

  describe "test the cache itself" do
    test "state updates after poll", %{name: name} do
      Process.sleep(100)

      data = AlphabeticNebulexCache.lookup(name)

      assert Map.has_key?(data, "germany")
      assert data["germany"] == "germany"
    end

    test "initial state loads from DB", %{name: name} do
      Process.sleep(100)
      data = AlphabeticNebulexCache.lookup(name)
      assert data["germany"] == "germany"
      assert data["usa"] == "usa"
    end
  end
end
