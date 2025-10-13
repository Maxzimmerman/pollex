import Config

config :pollex,
  ecto_repos: [Pollex.Repo]

config :pollex, Pollex.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "pollex_dev",
  pool_size: 10
