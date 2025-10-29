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
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache_runtime_opts: [
        gc_interval: :timer.hours(12),
        max_size: 1_000_000,
        allocated_memory: 2_000_000_000,
        gc_cleanup_min_timeout: :timer.seconds(10),
        gc_cleanup_max_timeout: :timer.minutes(10)
      ]
    },
    citiess: %{
      refresh_interval_seconds: 6,
      cache: {NebulexCacheAdapter, [columns: [:name]]},
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache_runtime_opts: [
        gc_interval: :timer.hours(12),
        max_size: 1_000_000,
        allocated_memory: 2_000_000_000,
        gc_cleanup_min_timeout: :timer.seconds(10),
        gc_cleanup_max_timeout: :timer.minutes(10)
      ]
    }
  }
