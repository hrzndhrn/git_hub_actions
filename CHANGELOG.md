# Changelog

## 0.3.2 2025/02/02

- Update `priv/default.exs` to improve readability.

## 0.3.1 2025/01/23

- Add Elixir version `1.18.2` to config

## 0.3.0 2024/12/30

- Add setup-beam-version to cache keys.
- Add `GitHubActions.Versions.minimize/1`
- Reduce jobs in the default workflow script.
- Update docs.
- Add Elixir version `1.18.1` to config

## 0.2.27 2024/12/23

- Add Elixir version `1.18.0` to config

## 0.2.26 2024/12/13

- Add Erlang version `27.2` to config

## 0.2.25 2024/09/23

- Add Elixir version `1.17.3` to config
- Add Erlang version `27.1` to config

## 0.2.24 2024/07/07

- Add Elixir version `1.17.2` to config
- Make `GitHubActions.Version` avaialable in workflow scripts
- Add the functions `GitHubActions.Version.major/1`, 
  `GitHubActions.Version.minor/1` and `GitHubActions.Version.patch/1`
- Add the option `--elixir`/`-e` to `mix gha`. The given version will be 
  available in the config.
- Update the default workflow script. The script will now use an Elixir version, 
  specified by `--elixir`, as the minimum version in the version matrix.

## 0.2.23 2024/06/23

- Update inspect implementation for `GitHubActions.Version`
- Require Elixir verions 1.13
- Add Elixir version `1.17.1` to config
- Add Erlang version `27.0` to config

## 0.2.22 2024/03/16

- Update to `actions/cache@v4`
- Update to `actions/checkout@v4`

## 0.2.21 2024/03/11

- Add Elixir version `1.16.2` to config

## 0.2.20 2024/02/10

- Add Elixir version `1.16.1` to config

## 0.2.19 2023/12/23

- Update config: Elixir version `1.16.0` supports OTP `26.2`
- Add flads `--format github` and `--force-check` for `dialyzer` in default
  config.


## 0.2.18 2023/11/12

- Update config: Elixir version `1.14.5` supports OTP `26.0`

## 0.2.17 2023/10/23

- Add Elixir version `1.15.7` to config

## 0.2.16 2023/09/29

- Add Elixir version `1.15.6` to config
- Add Erlang version `26.1` to config

## 0.2.15 2023/09/08

- Add Elixir version `1.15.5` to config

## 0.2.14 2023/07/22

- Add Elixir version `1.15.4` to config

## 0.2.13 2023/07/16

- Add Elixir version `1.15.3` to config

## 0.2.12 2023/07/03

- Add Elixir version `1.15.2` to config

## 0.2.11 2023/06/25

- Add Elixir version `1.15.0` to config

## 0.2.10 2023/05/24

- Add Elixir version `1.14.5` to config

## 0.2.9 2023/05/19

- Add Erlang version `26.0` to config

## 0.2.8 2023/04/03

- Add Elixir version `1.14.4` to config
- Add Erlang version `25.3` to config

## 0.2.7 2023/02/02

- Add Elixir version `1.14.3` to config

## 0.2.6 2022/12/18

- Add Erlang version `25.2` to config

## 0.2.5 2022/12/10

- Set `runs-on: ubuntu-20.04` for linux as default.

## 0.2.4 2022/11/19

- Update the job for windows
- Add Elixir version `1.14.2` to config

## 0.2.3 2022/11/09

- Use default `env` for the format check, unused check, credo, coverall and test

## 0.2.2 2022/10/14

- Add Elixir version `1.14.1` to config
- Update to `actions/cache@v3`

## 0.2.1 2022/09/23

- Add Erlang version `25.1` to config

## 0.2.0 2022/09/07

- Add a step for `mix dep.unlock --check-unused`

## 0.1.10 2022/07/04

- Run `dialyzer` only for latest erlang and Elixir version

## 0.1.9 2022/07/04

- Add Erlang version `25.0` to config

## 0.1.8 2022/06/26

- Add Elixir version `1.13.4` to config
- Update to `actions/checkout@v3`

## 0.1.7 2022/04/03

- Add Erlang version `24.3` to config
- Fix exclude key bug

## 0.1.6 2022/02/13

- Add Elixir version `1.13.3` to config
- Add Erlang version `24.2` to config

## 0.1.5 2022/01/30

- Add Elixir version `1.13.2` to config

## 0.1.4 2021/12/19

- Add Elixir version `1.13.1` to config

## 0.1.3 2021/12/12

- Add Elixir version `1.13.0` to config
- Run tests with coverage just for the latest version

## 0.1.2 2021/09/23

- Add Erlang version `24.1` to config

## 0.1.1 2021/09/05

- Use `erlef/setup-beam` instead of `erlef/setup-elixir`
- Add Elixir version `1.12.3` to config

## 0.1.0 2021/08/22

The very first version.
