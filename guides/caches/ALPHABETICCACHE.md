Configurable Cache System

This cache follows a different approach. The idea you configure a data set you wanna use (at the moment you can choose between csv and repo data). And pollex will start 24 Genserver under your supervison tree one for each letter in the alphabet. Then each server will hold the entries starting with that letter in its state.

# config/config.exs

```elixir
config :pollex, Pollex.Application,
    citiess: %{
        refresh_interval_seconds: 6,
        source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
        cache: {GenServerCacheAdapter, [columns: [:name]]}
    }
```

refresh_interval_seconds → how often the cache refreshes
source → defines the data source (table + repo)
cache → defines how the data is stored in the GenServer (e.g., which columns to fetch)

# Lookup

Once the cache is running, you can fetch data at any time

```elixir
iex> AlphabeticCache.lookup(:a)
iex>
[
    %{name: "australia"},
    %{name: "austria"}
]
```

There are more options you can find in the Docs 👇

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pollex>.