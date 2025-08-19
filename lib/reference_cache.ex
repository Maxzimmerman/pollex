defmodule ReferenceCache do
  def refresh() do datasets = Application.get_env(:pollex, __MODULE__)[:datasets]
    Enum.each(datasets, fn dataset ->
      IO.inspect(dataset)
      {source_mod, source_opts} = dataset.source
      {cache_mod, cache_opts} = dataset.cache

      data = source_mod.load(source_opts)
      cache_mod.store(cache_opts, data)
    end)
  end
end
