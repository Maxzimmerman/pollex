defmodule Pollex.SrcAdapter.CSVFileSourceAdapter do
  alias Pollex.SrcAdapter.CSVFileSourceAdapter

  @callback load(String.t()) :: {:ok, list()} | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      @behaviour CSVFileSourceAdapter

      @spec load(String.t()) :: {:ok, list()} | {:error, any()}
      def load(file_name) do
        file_path = Path.join(unquote(CSVFileSourceAdapter.seed_path()), file_name)

        case CSVFileSourceAdapter.read_csv(file_path) do
          {:ok, content} -> {:ok, content}
          {:error, reason} -> {:error, reason}
        end
      end
    end
  end

  @doc """
  This functions returns the path to the where the csvs live
  """
  @spec seed_path() :: Path.t()
  def seed_path do
    Path.expand("csvs/", File.cwd!())
  end

  @doc """
  This function reads a csv file of a given path and transforms the input to a elixir map
  """
  @spec read_csv(String.t()) :: {:ok, Enum.t()} | {:error, Exception.t() | {term(), term()}}
  def read_csv(file_path) do
    try do
      {:ok,
       file_path
       |> File.stream!()
       |> CSV.decode!(headers: true, field_transform: &String.trim/1, validate_row_length: true)
       |> Enum.into([])}
    rescue
      e -> {:error, e}
    catch
      kind, reason -> {:error, {kind, reason}}
    end
  end
end
