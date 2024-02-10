defmodule Mix.Tasks.Gha do
  @moduledoc """
  Creates a GitHub actions file.

  See [Usage](/git_hub_actions/usage.html) and
  [Defaults](/git_hub_actions/defaults.html) for more information.

  ## Command line options
  - `--config`, `-c` - specifies the config file
  - `--output`, `-o` - specifites the output file, defaults to
    `.github/workflows/ci.yml`
  - `--workflow`, `-w` - specifies the workflow script
  """

  @shortdoc "Creates a GitHuba actions yml-file"

  use Mix.Task

  @defaults [workflow: :default, config: :default, output: :default]

  @impl Mix.Task
  def run(options) do
    {opts, []} =
      OptionParser.parse!(options,
        strict: [workflow: :string, config: :string, output: :string],
        aliases: [w: :workflow, c: :config, o: :output]
      )

    @defaults
    |> Keyword.merge(opts)
    |> GitHubActions.run()
  rescue
    error in OptionParser.ParseError ->
      Mix.Shell.IO.error(Exception.format(:error, error, []))
      exit({:shutdown, 1})
  end
end
