import Config

# Configure your database
config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
