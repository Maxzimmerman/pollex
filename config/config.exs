import Config

config :pollex, Pollex.Application,
  datasets: %{
    unlocodes: %{
      refresh_interval_seconds: 60,
      source: {EctoSourceAdapter, [table: "cities"]},
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
