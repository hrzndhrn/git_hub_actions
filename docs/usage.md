# Usage

`GitHubActions` is a little tool to write GitHub actions in Elixir. This lib
is an early beta and is currently experimental.

## Install

`GitHubActions` can be installed as an archive.

```shell
$> mix archive.install hex git_hub_actions
```
Or, as a dependency.

``` elixir
def deps do
  [
    {:git_hub_actions, "~> 0.1", only: :dev}
  ]
end
```

## Create a workflow yml

`GitHubActions` comes with some default settings to create a workflow yml. You
can run `mix gha` in a project root directory to create
`.github/workflows/ci.yml`.

```shell
$> mix gha
* creating .github/workflows/ci.yml
```

See the [`Defaults`](#defaults) section for information on the defaults.

## Custom workflow and config

See `GitHubActions.Workflow` for how to write a workflow script.

The `mix` task `gha` comes with the options `--workflow` and `--config` to use
custom scripts. The config will be merged into the default config.

It is also possible to setup a `./.gha` directory in your home directory or in the
project root directory. The `mix` task `gha.config` with the options
`--gen-global` and `--gen-local` will copy the defaults to the related location.

The configuration will be read from `priv/config.exs` and afterward updated
by `~/.gha/config.exs` and then by `./.gha/config.exs`.

`GitHubActions` will search the workflow script in the order `./.gha/default.exs`,
`~/.gha/default.exs` and `priv/default.exs`. The name of the default script can
be changed in the configuration under `input: [default: "my_workflow.exs"]`.

## Defaults

The defaults create a workflow file that runs on `ubuntu-24.04`. The matrix is
created with the setting of `elixir` from the relevant project and the `OTP`
versions `> 21.0.0`.

The workflow file (e.g. `.github/workflows/ci.yml`) is created by a workflow
script. The default workflow script is in 
[`priv/default.exs`](https://github.com/hrzndhrn/git_hub_actions/blob/main/priv/default.exs).

The workflow script uses data from the config. The default config is in
[`priv/config.exs`](https://github.com/hrzndhrn/git_hub_actions/blob/main/priv/config.exs).

The `linux` job gets the following steps:
- `checkout`
- `setup_elixir`, using `erlef/setup-elixir@v1`
- `restore(:deps)`, can be suppressed by config
- `restore(:_build)`, can be suppressed by config
- `restore(:dialyxir)`, when `:dialyxir` is part of the dependencies,
  can be suppressed by config
- `get_deps`
- `compile_deps`
- `compile`, with `--warnings-as-errors`
- `check_code_format`, can be suppressed by config, executes only for the latest
   Elixir/OTP version
- `lint_code`, when `:credo` is part of the dependencies, executes only for the
  latest Elixir/OTP version
- `run_tests`
- `dialyxir`, when `:dialyxir` is part of the dependencies

The workflow script also contains jobs for `macOS` and `Windows`.  To activate
these jobs, set `config :jobs, [:linux, :macos, :windows]` in the config.  The
jobs for `macOS` and `Windows` use just the latest Elixir/OTP version.
