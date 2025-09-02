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

## [0.2.1] - 02.09.2025
- Provied a fix so the package won't crash now because it only uses the started repo of the consuming application.

## [0.2.2] - 02.09.2025 
- Provied a fix so the package won't crash now because the consuming package has to start it so it won't be started before the consuming Application repo