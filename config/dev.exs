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
      cache: {NebulexCacheAdapter, [columns: [:name]]},
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]}
    }
  }
