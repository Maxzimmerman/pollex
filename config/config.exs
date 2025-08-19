import Config

config :pollex, ReferenceCache,
      datasets: %{
      unlocodes: %{
      refresh_interval_seconds: 60,
      source: {EctoSourceAdapter, [table: "references_unlocodes", columns: [:code]]},
      cache: {GenServerCacheAdapter, []}
    }
}
