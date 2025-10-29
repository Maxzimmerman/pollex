defmodule NebulexCacheTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  alias Pollex.{Repo, City}
  alias Pollex.NebulexCache

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

      assert NebulexCache.transform_to_nebulex_format(data) == expected
    end

    property "returns a valid nebulex data forma" do
      check all(data <- generate_map()) do
        result = Pollex.NebulexCache.transform_to_nebulex_format(data)

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
