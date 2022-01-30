# GitHubActions
[![Hex.pm: version](https://img.shields.io/hexpm/v/git_hub_actions.svg?style=flat-square)](https://hex.pm/packages/git_hub_actions)
[![GitHub: CI status](https://img.shields.io/github/workflow/status/hrzndhrn/git_hub_actions/CI?style=flat-square)](https://github.com/hrzndhrn/git_hub_actions/actions)
[![Coveralls: coverage](https://img.shields.io/coveralls/github/hrzndhrn/git_hub_actions?style=flat-square)](https://coveralls.io/github/hrzndhrn/git_hub_actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/hrzndhrn/git_hub_actions/blob/main/LICENSE.md)

`GitHubAction` is a little tool to write GitHub actions in Elixir. This lib
is an early beta and is currently experimental.

You can find the [usage](https://hexdocs.pm/git_hub_actions/usage.html)
documentation on [hexdocs](https://hexdocs.pm/git_hub_actions).

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

The default conifg and the informations to customise the workflow yml generation
can be found in the [documentation](https://hexdocs.pm/git_hub_actions/usage.html).
