import Config

config :pollex, ReferenceCache,
  datasets: %{
    unlocodes: %{
      refresh_interval_seconds: 60,
      source: {EctoAdapter, [table: "references_unlocodes", columns: [:code]]},
      cache: {GenserverCacheAdapter, []}
    }
}
