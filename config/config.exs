import Config

config :pollex, Pollex.Application,
  datasets: %{
    cities: %{
      refresh_interval_seconds: 3,
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache: {GenServerCacheAdapter, [columns: [:name]]}
    }
  }

config :pollex,
  ecto_repos: [Pollex.Repo]

# Configure your database
config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
