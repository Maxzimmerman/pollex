defmodule AlphabeticNebulexCacheTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  alias Pollex.{Repo, City}
  alias Pollex.AlphabeticNebulexCache

  # --- Test adapter to override "starting_with" behavior ---
  defmodule TestAdapter do
    use Pollex.SrcAdapter.AlphabeticAdapter

    @impl true
    def load(table, repo, columns, _starting_with, _query_column) do
      query =
        from(t in table,
          select: map(t, ^columns),
          distinct: true
        )

      {:ok, repo.all(query)}
    end
  end

  # Helper to start a cache GenServer for a specific starting letter
  defp start_cache(letter) do
    start_supervised!(
      {AlphabeticNebulexCache,
       [
         name: letter,
         query_column: :name,
         source_opts: [table: City, repo: Repo],
         cache_opts: [columns: [:name]],
         refresh_rate: 1,
         cache_runtime_opts: [
           gc_interval: :timer.hours(12),
           max_size: 1_000_000,
           allocated_memory: 2_000_000_000,
           gc_cleanup_min_timeout: :timer.seconds(10),
           gc_cleanup_max_timeout: :timer.minutes(10)
         ],
         __adapter__: TestAdapter
       ]}
    )
  end

  # --- Individual tests ---

  test "cache loads initial state" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    # Insert test data
    Repo.insert!(%City{name: "germany"})
    Repo.insert!(%City{name: "usa"})

    # Start cache for the first letter of "germany"
    letter = String.first("germany") |> String.to_atom()
    pid = start_cache(letter)

    on_exit(fn ->
      # Kill the GenServer after test
      if Process.alive?(pid), do: GenServer.stop(pid)
    end)

    Process.sleep(100)
    data = AlphabeticNebulexCache.lookup(letter)

    assert Enum.any?(Map.values(data), fn
             {:value, %{name: "germany"}} -> true
             _ -> false
           end)
  end

  test "cache updates after poll" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    Repo.insert!(%City{name: "france"})

    letter = String.first("france") |> String.to_atom()
    pid = start_cache(letter)

    on_exit(fn ->
      # Kill the GenServer after test
      if Process.alive?(pid), do: GenServer.stop(pid)
    end)

    # Force a poll
    send(letter, :poll)
    Process.sleep(100)

    data = AlphabeticNebulexCache.lookup(letter)

    assert Enum.any?(Map.values(data), fn
             {:value, %{name: "france"}} -> true
             _ -> false
           end)
  end
end
