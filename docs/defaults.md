# Defaults

The defaults create a workflow file that runs on `ubuntu-20.04`. The matrix is
created with the setting of `elixir` from the relevant project and the `OTP`
versions >= 20.

The workflow file is (e.g. `.github/workflows/ci.yml`) is created by a workflow
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
