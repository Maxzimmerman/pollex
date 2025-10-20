# Pollex

Pollex provides two core features:

1. lightweight polling engine built with a simple GenServer implementation.

2. configurable cache system that spins up a dynamically supervised GenServer for each dataset. The cache stores data fetched from a configured Ecto Repo, keeping it readily available in memory.

## Features

✅ Lightweight polling engine using native GenServer
🔁 Customizable polling intervals
📦 Configurable cache system with per-dataset supervised GenServers
🗄️ Built-in integration with Ecto for data fetching
🔌 Plug-and-play architecture for OTP applications
⚡ Efficient and production-ready

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `pollex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pollex, "~> 0.4.8"}
  ]
end
```

## Getting Started

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
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache: {GenServerCacheAdapter, [columns: [:name]]}
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

