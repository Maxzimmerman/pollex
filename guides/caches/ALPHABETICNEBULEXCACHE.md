Configurable Cache System

The cache system lets you declare datasets in your config. Each dataset will start its own supervised GenServer, which fetches data from a configured source (such as an Ecto Repo) and keeps it cached in memory. It implements Nebulex to get even more options including runntime options.

What happends under the hood:
Pollex will create 24 Genservers under your supervision tree.
Each Genserver has one letter in the alphabet as name.
A Genserver will only return entries for which the configured query_column starts with the name of the Genserver. 
Each Genserver generates dynamic module which implementes the Nebulex module.
This submodule is used to actually store the data the Genserver is like an interface with which you can access the data conviently.

# config/config.exs

```elixir
config :pollex, Pollex.Application,
  datasets: %{
    cities: %{
      refresh_interval_seconds: 6,
      query_column: :name,
      cache: {NebulexCacheAdapter, [columns: [:name, :country]]},
      source: {AlphabeticAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache_runtime_opts: [
        gc_interval: :timer.hours(12),
        max_size: 1_000_000,
        allocated_memory: 2_000_000_000,
        gc_cleanup_min_timeout: :timer.seconds(10),
        gc_cleanup_max_timeout: :timer.minutes(10)
      ]
    }
  }
```

refresh_interval_seconds → how often the cache refreshes
source → defines the data source (table + repo)
cache → defines how the data is stored in the GenServer (e.g., which columns to fetch)
and other runntime options used by nebulex

# Lookup

Once the cache is running, you can fetch data at any time

```elixir
iex> AlphabeticNebulexCache.lookup(:a)
iex>
%{
"australia" => "australia",
"austria" => "austria",
"azerbaijan" => "azerbaijan",
}
```

There are more options you can find in the Docs 👇

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/pollex>.

Also when you want to read more about the runntime options [ExDoc](https://hex.pm/packages/nebulex) 