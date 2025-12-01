defmodule Helpers.NebulexTest do
  use ExUnit.Case, async: false
  use ExUnitProperties

  alias Pollex.Helpers.Nebulex, as: NebulexHelpers

  describe "transform_to_nebulex_format/1" do
    test "transforms list of maps into a map keyed by sorted order of first value" do
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
        0 => {:value, %{country: "australia"}},
        1 => {:value, %{iso: "austria"}},
        2 => {:value, %{abbr: "azerbaijan"}},
        3 => {:value, %{name: "germany"}},
        4 => {:value, %{region: "russia"}},
        5 => {:value, %{label: "united kingdom"}},
        6 => {:value, %{code: "usa"}}
      }

      assert NebulexHelpers.transform_to_nebulex_format(data) == expected
    end

    property "returns a valid nebulex data format" do
      check all(data <- generate_map()) do
        result = NebulexHelpers.transform_to_nebulex_format(data)

        # Result should be a map
        assert is_map(result)

        # All values in result are wrapped correctly
        assert Enum.all?(Map.values(result), fn {:value, map} -> map in data end)

        # No extra values
        assert length(Map.values(result)) == length(data)
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
