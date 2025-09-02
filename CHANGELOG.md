## [0.2.0] - 02.09.2025 
- Added a new ecto/genserver caching system configurable in the config
- You configure one cache genserver per dataset
- The genservers will automatically run under you supervisor tree managed by a Dynamic Supervisor

Example:
 
 config :pollex, Pollex.Application,
  datasets: %{
    cities: %{
      refresh_interval_seconds: 3,
      source: {EctoSourceAdapter, [table: Pollex.City, repo: Pollex.Repo]},
      cache: {GenServerCacheAdapter, [columns: [:name]]}
    }
  }

So you define the dataset, an interval and which caching system you wanna use because in the future other strategies will follow.
