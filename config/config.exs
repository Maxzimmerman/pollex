import Config

config :pollex,
  ecto_repos: [Mosaic.Repo]

# Configure your database
config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :pollex, Pollex.Application,
  opts: %{
    refresh_interval_seconds: 3,
    source: {AlphabeticCacheAdapter, [table: Pollex.City, repo: Pollex.Repo]},
    cache: {GenServerCacheAdapter, [columns: [:name]]}
  }
