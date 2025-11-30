defmodule Pollex.Helpers.Nebulex do
  def transform_to_nebulex_format(data) do
    data
    |> Enum.with_index()
    |> Map.new(fn {entry, index} ->
      {index, {:value, entry}}
    end)
  end
end
