defmodule SrcAdapter.CSVFileSourceAdapter do
  @callback load(String.t()) :: {:ok, list()} | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.CSVFileSourceAdapter

      @spec load(String.t()) :: {:ok, list()} | {:error, any()}
      def load(file_name) do
        file_path = Path.join(unquote(SrcAdapter.CSVFileSourceAdapter.seed_path()), file_name)

        case SrcAdapter.CSVFileSourceAdapter.read_csv(file_path) do
          {:ok, content} -> {:ok, content}
          {:error, reason} -> {:error, reason}
        end
      end
    end
  end

  def seed_path do
    Path.expand("csvs/", File.cwd!())
  end

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
