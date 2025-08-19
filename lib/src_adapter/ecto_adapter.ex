defmodule SrcAdapter.EctoAdapter do
  @callback load(configuration :: Keyword.t()) :: [map()]

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour SrcAdapter.EctoAdapter

      @spec load(Keyword.t()) :: [map()]
      def load(_configuration) do
        raise "load/1 must be implemented"
      end

      defoverridable load: 1
    end
  end
end
