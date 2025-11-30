defmodule Pollex.Helpers.Nebulex do
  def transform_to_nebulex_format(data) do
    data
    |> Enum.with_index()
    |> Map.new(fn {entry, index} ->
      {Integer.to_string(index), entry}
    end)
  end
end
