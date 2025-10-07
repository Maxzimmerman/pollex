defmodule Pollex.SrcAdapter.AlphabeticAdapter do
  @callback load(
              table :: Ecto.Schema.t(),
              repo :: module(),
              columns :: list(atom()),
              starting_with :: binary()
            ) :: {:ok, list() | {:error, any()}}

  @spec __using__(any()) :: any()
  defmacro __using__(_opts) do
    quote do
      @behaviour Pollex.SrcAdapter.AlphabeticAdapter
      import Ecto.Query

      @spec load(Ecto.Schema.t(), module(), list(), binary()) ::
              {:ok, list()} | {:error, any()}
      @impl true
      def load(table, repo, columns, starting_with) do
        try do
          query =
            from(t in table,
              where: ilike(t.name, ^"#{starting_with}%"),
              select: map(t, ^columns),
              distinct: true
            )

          data = repo.all(query)
          {:ok, data}
        rescue
          e -> {:error, e}
        end
      end

      defoverridable load: 4
    end
  end
end
