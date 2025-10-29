defmodule Pollex.MixProject do
  use Mix.Project

  def project do
    [
      app: :pollex,
      version: "0.5.11",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An Elixir polling and HTTP abstraction library",
      package: package(),
      name: "pollex",
      source_url: "https://github.com/Maxzimmerman/pollex",
      docs: docs(),
      aliases: aliases()
    ]
  end

  def docs do
    [
      main: "readme",
      extras: [
        "README.md": [title: "Overview"],
        "guides/caches/GETTING_STARTED.md": [title: "Getting Started"],
        "guides/caches/ECTOGENSERVERCACHE.md": [title: "EctoGenServerCache"],
        "guides/caches/CSVGENSERVERCACHE.md": [title: "CSVGenServerCache"],
        "guides/caches/ALPHABETICCACHE.md": [title: "AlphabeticCache"]
      ],
      groups_for_extras: [
        Tutorials: [
          "guides/caches/GETTING_STARTED.md",
          "guides/caches/ECTOGENSERVERCACHE.md",
          "guides/caches/CSVGENSERVERCACHE.md",
          "guides/caches/ALPHABETICCACHE.md"
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Pollex.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:mox, "~> 1.2.0", only: :test},
      {:ex_doc, "~> 0.12"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:csv, "~> 3.2"},
      {:nebulex, "~> 2.6"},
      {:shards, "~> 1.0"},
      {:decorator, "~> 1.4"},
      {:stream_data, "~> 1.2"}
    ]
  end

  defp package do
    [
      maintainers: ["Max Zimmermann"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Maxzimmerman/pollex"
      }
    ]
  end

  defp aliases do
    [
      check: ["format", "dialyzer", "test", "credo --strict"],
      "ecto.setup": ["ecto.create", "ecto.migrate"]
    ]
  end
end
