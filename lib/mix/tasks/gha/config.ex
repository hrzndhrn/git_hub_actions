defmodule Mix.Tasks.Gha.Config do
  @moduledoc """
  Creates a `GitHubActions` directory with config and default workflow.

  The config file gets the name `config.exs` and the default workflow gets the
  name `defaults.exs`.

  ## Command line options
  - `--gen-global` - creates `~/.gha`
  - `--gen-local` - creates `.gha`
  """

  @shortdoc "Creates a `GitHubActions` directory with config and default workflow."

  use Mix.Task

  @impl Mix.Task
  def run(options) do
    {opts, []} =
      OptionParser.parse!(options,
        strict: [gen_global: :boolean, gen_local: :boolean]
      )

    GitHubActions.copy(opts)
  rescue
    error ->
      Mix.Shell.IO.error(Exception.format(:error, error, []))
      exit({:shutdown, 1})
  end
end
