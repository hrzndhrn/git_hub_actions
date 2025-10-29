defmodule Mix.Tasks.Gha do
  @moduledoc """
  Creates a GitHub actions file.

  See [Usage](/git_hub_actions/usage.html) and
  [Defaults](/git_hub_actions/defaults.html) for more information.

  ## Command line options
  - `--config`, `-c` - specifies the config file
  - `--elixir`, `-e` - puts the given Elixir version to the config
  - `--output`, `-o` - specifites the output file, defaults to
    `.github/workflows/ci.yml`
  - `--workflow`, `-w` - specifies the workflow script
  """

  @shortdoc "Creates a GitHuba actions yml-file"

  use Mix.Task

  alias GitHubActions.Config

  @defaults [workflow: :default, config: :default, output: :default]

  @impl Mix.Task
  def run(options) do
    {opts, []} =
      OptionParser.parse!(options,
        strict: [workflow: :string, config: :string, output: :string, elixir: :string],
        aliases: [w: :workflow, c: :config, o: :output, e: :elixir]
      )

    config_elixir_version(opts)

    @defaults
    |> Keyword.merge(opts)
    |> GitHubActions.run()
  rescue
    error in OptionParser.ParseError ->
      Mix.Shell.IO.error(Exception.format(:error, error, []))
      exit({:shutdown, 1})
  end

  defp config_elixir_version(opts) do
    if Keyword.has_key?(opts, :elixir) do
      version =
        opts
        |> Keyword.get(:elixir)
        |> GitHubActions.Version.parse!()

      Config.config(:elixir, version)
    end
  rescue
    _error in GitHubActions.InvalidVersionError ->
      Mix.Shell.IO.error("The given Elixir version is invalid.")
      exit({:shutdown, 1})
  end
end
