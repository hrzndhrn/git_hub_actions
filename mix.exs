defmodule GitHubActions.MixProject do
  use Mix.Project

  @source_url "https://github.com/hrzndhrn/git_hub_actions"
  @version "0.3.11"

  def project do
    [
      app: :git_hub_actions,
      version: @version,
      elixir: "~> 1.13",
      name: "GitHubActions",
      description: "A little tool to write GitHub actions in Elixir",
      source_url: @source_url,
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      test_ignore_filters: [~r'test/support/.*', ~r'test/fixtures/.*'],
      package: package()
    ]
  end

  def docs() do
    [
      main: "usage",
      formatters: ["html"],
      source_ref: "v#{@version}",
      extras: ["docs/usage.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [
        carp: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp dialyzer do
    [
      flags: [:error_handling],
      plt_add_apps: [:mix],
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"},
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  defp aliases do
    [carp: "test --seed 0 --max-failures 1 --trace"]
  end

  defp deps do
    [
      # dev/test
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.25", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.15", only: [:dev, :test]},
      {:mock, "~> 0.3", only: :test},
      {:prove, "~> 0.1", only: [:dev, :test]},
      {:recode, "~> 0.1", only: :dev},
      {:yamerl, "~> 0.8", only: [:dev, :test]}
    ]
  end
end
