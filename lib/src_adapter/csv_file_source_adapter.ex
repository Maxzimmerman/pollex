defmodule SrcAdapter.CSVFileSourceAdapter do
  @callback load(String.t()) :: {:ok, list()} | {:error, any()}

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)

      def load(file_name) do
        file_path = Path.join(unquote(seed_path()), file_name)

        if Path.extname(file_path) == ".csv" do
          content =
            file_path
            |> File.stream!()
            |> CSV.decode!(headers: true, field_transformed: &String.trim/1, validate_row_length: true)
            |> Enum.into([])

          {:ok, content}
        else
          {:error, "File not found"}
        end
      end
    end
  end

  defp seed_path do
    Path.expand("csvs/", File.cwd!())
  end
end
