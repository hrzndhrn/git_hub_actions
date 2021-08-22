# Usage

`GitHubActions` is a little tool to write GitHub actions in Elixir. This lib
is an early beta and is currently experimental.

## Install

`GitHubActions` can be installed as an archive.

```shell
$> mix arcive.install hex :git_hub_actions
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

The [defaults](/git_hub_actions/defaults.html) are
[piv/config.exs](/git_hub_actions/defaults.html#config.exs)
and
[piv/default.exs](/git_hub_actions/defaults.html#default.exs).

## Custom workflow and config

See `GitHubActions.workflow` for how to write a workflow script.

The `mix` task `gha` comes with the options `--workflow` and `--config` to use
custom scripts. The config will be merged into the default config.

It is also possible to setup a `./.gha` directory in your home directory or in the
project root directory. The `mix` task `gha.config` with the options
`--gen-global` and `--gen-local` will copy the defaults to the related location.

The configuration will be read from `priv/config.exs` and afterward updated
by `~/.gha/config.exs` and then by `./.gha/config.exs`.

`GitHubActions` will search the workflow script in the order `./.gha/default.exs`,
`~/.gha/default.exs` and `priv/default.exs`. The name of the default script can
be changed in the configuration und `input: [default: "my_workflow.exs"]`.
