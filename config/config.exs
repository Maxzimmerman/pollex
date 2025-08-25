import Config

config :pollex, Pollex.Application,
  datasets: %{
    unlocodes: %{
      refresh_interval_seconds: 60,
      source: {EctoSourceAdapter, [table: "references_unlocodes", columns: [:code]]},
      cache: {GenServerCacheAdapter, []}
    }
}
