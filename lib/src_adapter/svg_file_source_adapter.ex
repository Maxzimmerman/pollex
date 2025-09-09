defmodule SrcAdapter.SvgFileSourceAdapter do
  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.SvgFileSourceAdapter

      def load(file_path) do
        if Path.extname(file_path) == ".svg" do
          with {:ok, content} <- File.read(file_path) do
            content
          else
            {:error, :enoent} -> raise "Could not find file."
          end
        end
      end
      defoverridable load: 1
    end
  end
end
