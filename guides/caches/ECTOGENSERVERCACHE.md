Configurable Cache System

The cache system lets you declare datasets in your config. Each dataset will start its own supervised GenServer, which fetches data from a configured source (such as an Ecto Repo) and keeps it cached in memory.

There are also some introduction videos showing how to use this package
Ecto/GenServer
https://www.loom.com/share/ccc4e382d5734f5897ed346b0da21323

# config/config.exs

```elixir
config :pollex, Pollex.Application,
  datasets: %{
    cities: %{
      refresh_interval_seconds: 6,
      cache: {GenServerCacheAdapter, [columns: [:name]]},
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]}
    }
  }
```

refresh_interval_seconds → how often the cache refreshes
source → defines the data source (table + repo)
cache → defines how the data is stored in the GenServer (e.g., which columns to fetch)

# Lookup

Once the cache is running, you can fetch data at any time

```elixir
iex> EctoGenServerCache.lookup(:cities)
[
  %{name: "germany"},
  %{name: "usa"},
  %{name: "australia"},
  %{name: "united kingdom"},
  %{name: "austria"}
]
```

There are more options you can find in the Docs 👇

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pollex>.