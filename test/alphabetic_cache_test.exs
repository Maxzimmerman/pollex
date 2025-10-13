defmodule AlphabeticCacheTest do
  use ExUnit.Case, async: false

  alias Pollex.{Repo, City}
  alias Pollex.AlphabeticCache

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    name = :a
    source_opts = [table: City, repo: Repo]
    cache_opts = [columns: [:name]]
    interval = 1

    pid =
      start_supervised!(
        {AlphabeticCache,
         [
           name: name,
           source_opts: source_opts,
           cache_opts: cache_opts,
           refresh_rate: interval
         ]}
      )

    {:ok, name: name, pid: pid}
  end

  test "check inital state is not nil", %{name: name} do
    Process.sleep(100)

    data = AlphabeticCache.lookup(name)
    assert data != nil
    assert data == []
  end

  test "check filtered state", %{name: name} do
    Repo.insert!(%City{name: "azerbaijan"})
    Repo.insert!(%City{name: "russia"})

    Process.sleep(1000)

    data = AlphabeticCache.lookup(name)

    expected_data = %{name: "azerbaijan"}
    not_expected_data = %{name: "russia"}

    assert Enum.member?(data, expected_data)
    refute Enum.member?(data, not_expected_data)
  end
end
