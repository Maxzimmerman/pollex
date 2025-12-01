defmodule Pollex.SrcAdapter.AlphabeticAdapter do
  @callback load(
              table :: Ecto.Schema.t(),
              repo :: module(),
              columns :: list(atom()),
              starting_with :: binary(),
              query_column :: binary()
            ) :: {:ok, list() | {:error, any()}}

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour Pollex.SrcAdapter.AlphabeticAdapter
      import Ecto.Query

      @spec load(Ecto.Schema.t(), module(), list(), binary(), binary()) ::
              {:ok, list()} | {:error, any()}
      @impl true
      def load(table, repo, columns, starting_with, query_column) do
        try do
          query =
            from(t in table,
              where: ilike(field(t, ^query_column), ^"#{starting_with}%"),
              select: map(t, ^columns),
              distinct: true
            )

          data = repo.all(query)
          {:ok, data}
        rescue
          e -> {:error, e}
        end
      end

      defoverridable load: 5
    end
  end
end
