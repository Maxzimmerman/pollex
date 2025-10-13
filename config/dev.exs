import Config

config :pollex,
  ecto_repos: [Pollex.Repo]

config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_dev",
  pool_size: 10

config :pollex, Pollex.Application,
  datasets: %{
    cities: %{
      refresh_interval_seconds: 6,
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache: {AlphabeticAdapter, [columns: [:name]]}
    },
    citiess: %{
      refresh_interval_seconds: 6,
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache: {GenServerCacheAdapter, [columns: [:name]]}
    },
  },
  csvs: %{
        countries: %{
            refresh_interval_seconds: 3,
            source: {CSVFileSourceAdapter, []},
            cache: {GenServerCacheAdapter, []}
        }
      }
