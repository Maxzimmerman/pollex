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

## [0.2.3] - 03.09.2025
- Updated the documentation

## [0.3.3] - 11.09.2025
- Added a new ecto/genserver caching system configurable in the config
- You configure one one cache strategy and the system will spawn a genserver for each letter in the alphabet, so 24. Each Genserver fetches entries with the name field starting with the letter
- The genservers will automatically run under you supervisor tree managed by a Dynamic Supervisor

Example:
 
 config :pollex, Pollex.Application,
  opts: %{
    refresh_interval_seconds: 3,
    source: {AlphabeticCacheAdapter, [table: Pollex.City, repo: Pollex.Repo]},
    cache: {GenServerCacheAdapter, [columns: [:name]]}
  }

You can then fetch the entries matching the letter like this

  iex> AlphabeticCache.lookup(:a)
      iex>
      [
        %{name: "australia"},
        %{name: "austria"}
      ]

## [0.3.4] - 11.09.2025
- Fixed dynamic Repo selection


## [0.4.4] - 12.09.2025
- Added Cache which reads from a given file

## [0.4.5] - 07.10.2025
- Added dedicated tutorials for each cache

## [0.4.6] - 13.10.2025
- Made using the package easier since you now don't have to start the caches yourselfes
- Alidned the config for the alphabetic cache with Ecto-GenServer cache

## [0.4.7] - 20.10.2025
- Created a initialize dataset module which checks if the consumer provided a repo.

## [0.4.8] - 20.10.2025
- Removed some debugging lines.

## [0.4.9] - 20.10.2025
- Made the dataset initializer retry.

## [0.4.10] - 20.10.2025
- Restricted the retries when repo not ready to 10.

## [0.4.11] - 20.10.2025
- Updated the documentation for each cache strategy.
