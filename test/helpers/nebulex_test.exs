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

    property "returns Option A nebulex formatted data" do
      check all(data <- generate_map()) do
        result = NebulexHelpers.transform_to_nebulex_format(data)

        assert is_map(result)

        if data == [] do
          assert result == %{}
        else
          sorted =
            Enum.sort_by(data, fn map ->
              map |> Map.values() |> List.first()
            end)

          assert Map.keys(result) == Enum.to_list(0..(length(sorted) - 1))

          assert Enum.with_index(sorted)
                 |> Enum.all?(fn {map, index} ->
                   result[index] == {:value, map}
                 end)
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
