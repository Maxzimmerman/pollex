import Config

config :pollex,
  ecto_repos: [Pollex.Repo]

config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
