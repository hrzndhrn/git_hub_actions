defmodule GitHubActions.MixProject do
  use Mix.Project

  @github "https://github.com/hrzndhrn/git_hub_actions"

  def project do
    [
      app: :git_hub_actions,
      version: "0.1.0",
      elixir: "~> 1.11",
      name: "GitHubActions",
      description: "A little tool to write GitHub actions in Elixir",
      source_url: @github,
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      package: package()
    ]
  end

  def docs() do
    [
      main: "usage",
      extras: [
        "docs/usage.md",
        "docs/defaults.md"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Marcus Kruse"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github}
    ]
  end

  def preferred_cli_env do
    [
      carp: :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.travis": :test,
      "coveralls.html": :test,
      "gen.test_suite": :test
    ]
  end

  defp dialyzer do
    [
      flags: [:error_handling],
      plt_add_apps: [:mix],
      plt_file: {:no_warn, "test/support/plts/dialyzer.plt"}
    ]
  end

  defp aliases do
    [carp: "test --seed 0 --max-failures 1 --trace"]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.25", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:mock, "~> 0.3", only: :test},
      {:prove, "~> 0.1", only: [:dev, :test]},
      {:yamerl, "~> 0.8", only: [:dev, :test]}
    ]
  end
end
