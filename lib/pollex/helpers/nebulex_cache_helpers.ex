defmodule Pollex.Helpers.Nebulex do
  def transform_to_nebulex_format(data) when is_list(data) do
    data
    |> Enum.map(fn map ->
      {_key, value} = Enum.at(map, 0)
      # use value as string for deterministic sorting
      {to_string(value), map}
    end)
    |> Enum.sort_by(fn {value_str, _map} -> value_str end)
    |> Enum.with_index()
    |> Enum.into(%{}, fn {{_value_str, map}, index} -> {index, {:value, map}} end)
  end
end
