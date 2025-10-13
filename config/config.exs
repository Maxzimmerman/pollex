import Config

config :pollex,
  ecto_repos: [Pollex.Repo]

import_config "#{config_env()}.exs"
