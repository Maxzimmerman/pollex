Configurable Cache System

The cache system lets you declare csv datasets in your config. Each dataset will start its own supervised GenServer, which fetches data from a configured source (such as an Ecto Repo) and keeps it cached in memory.

# setting up the source files

You will need have a csvs folder in the top lever of your application.
In there you can define your csv data and you are good to go

# config/config.exs

```elixir
config :pollex, Pollex.Application,
    csvs: %{
        countries: %{
            refresh_interval_seconds: 3,
            source: {CSVFileSourceAdapter, []},
            cache: {GenServerCacheAdapter, []}
        }
}
```

refresh_interval_seconds → how often the cache refreshes
source → defines the data source (table + repo)
cache → defines how the data is stored in the GenServer (e.g., which columns to fetch)

# Lookup

Once the cache is running, you can fetch data at any time

```elixir
iex> CSVGenServerCache.lookup(:cities)
iex>
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