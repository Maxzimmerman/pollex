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

  describe "transform_to_nebulex_format/1" do
    test "transforms list of maps into a map keyed by the first value string of each map" do
      data = [
        %{name: "germany"},
        %{code: "usa"},
        %{country: "australia"},
        %{label: "united kingdom"},
        %{iso: "austria"},
        %{abbr: "azerbaijan"},
        %{region: "russia"}
      ]

      expected = %{
        "australia" => %{country: "australia"},
        "austria" => %{iso: "austria"},
        "azerbaijan" => %{abbr: "azerbaijan"},
        "germany" => %{name: "germany"},
        "russia" => %{region: "russia"},
        "united kingdom" => %{label: "united kingdom"},
        "usa" => %{code: "usa"}
      }

      assert AlphabeticNebulexCache.transform_to_nebulex_format(data) == expected
    end

    property "returns a valid nebulex data forma" do
      check all(data <- generate_map()) do
        result = AlphabeticNebulexCache.transform_to_nebulex_format(data)

        assert is_map(result)

        assert Enum.all?(Map.values(result), &(&1 in data))

        for {_k, v} <- result do
          [{_key, value}] = Map.to_list(v)
          assert Map.has_key?(result, to_string(value))
        end
      end
    end
  end

  defp generate_map do
    StreamData.list_of(
      StreamData.map_of(
        StreamData.atom(:alphanumeric),
        StreamData.string(:alphanumeric),
        min_length: 1,
        max_length: 1
      )
    )
  end
end
