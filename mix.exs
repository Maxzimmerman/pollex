defmodule Pollex.MixProject do
  use Mix.Project

  def project do
    [
      app: :pollex,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An Elixir polling and HTTP abstraction library",
      package: package(),
      name: "pollex",
      source_url: "https://github.com/Maxzimmerman/pollex",
      docs: [main: "readme", extras: ["README.md"]],
      aliases: aliases()
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
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
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
      check: ["format", "dialyzer", "test", "credo --strict"]
    ]
  end
end
