defmodule Pollex.Helpers.Nebulex do
  def transform_to_nebulex_format(data) do
    Map.new(data, fn entry ->
      case Map.to_list(entry) do
        [{_key, value} | _] ->
          {to_string(value), entry}

        [] ->
          {nil, entry}
      end
    end)
    |> Map.drop([nil])
  end
end
