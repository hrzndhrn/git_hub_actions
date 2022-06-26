# Defaults

The defaults create a workflow file that runs on `ubuntu-latest`. The matrix is
created with the setting of `elixir` from the relevant project and the `OTP`
versions >= 20.

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

## config.exs

```elixir
import GitHubActions.Config

config :output,
  comment: true,
  path: ".github/workflows",
  file: "ci.yml"

config :input,
  default: "default.exs"

config :steps,
  refresh: true,
  check_code_format: true,
  dialyxir: true,
  coveralls: :github

config :mix,
  env: nil

# Specifies for which OSs jobs are generated. Possible values :linux,
# :windows and :macos.
config :jobs, [:linux]

# Specifies the linux distribution.
config :linux,
  name: "Ubuntu",
  runs_on: "ubuntu-latest"

# Specifies the macos version.
config :macos,
  name: "macOS",
  runs_on: "macos-latest"

# Specifies the windows version.
config :windows,
  name: "Windows",
  runs_on: "windows-latest"

config versions: [
         [
           otp: ["17.0/5"],
           elixir: [
             "1.0.0/5",
             "1.1.0/1"
           ]
         ],
         [
           otp: ["18.0/3"],
           elixir: [
             "1.0.5",
             "1.1.0/1",
             "1.2.0/6",
             "1.3.0/4",
             "1.4.0/5",
             "1.5.0/3"
           ]
         ],
         [
           otp: ["19.0/3"],
           elixir: [
             "1.2.6",
             "1.3.0/4",
             "1.4.0/5",
             "1.5.0/3",
             "1.6.0/6",
             "1.7.0/4"
           ]
         ],
         [
           otp: ["20.0/3"],
           elixir: [
             "1.4.5",
             "1.5.0/3",
             "1.6.0/6",
             "1.7.0/4",
             "1.8.0/2",
             "1.9.0/4"
           ]
         ],
         [
           otp: ["21.0/3"],
           elixir: [
             "1.6.6",
             "1.7.0/4",
             "1.8.0/2",
             "1.9.0/4",
             "1.10.0/4",
             "1.11.0/4"
           ]
         ],
         [
           otp: ["22.0/3"],
           elixir: [
             "1.7.0/4",
             "1.8.0/2",
             "1.9.0/4",
             "1.10.0/4",
             "1.11.0/4",
             "1.12.0/2"
           ]
         ],
         [
           otp: ["23.0/3"],
           elixir: [
             "1.10.3/4",
             "1.11.0/4",
             "1.12.0/2"
           ]
         ],
         [
           otp: ["24.0/1"],
           elixir: [
             "1.11.4",
             "1.12.0/2"
           ]
         ]
       ]
```

## default.exs
```elixir
defmodule GitHubActions.Default do
  use GitHubActions.Workflow

  def workflow do
    [
      name: "CI",
      env: [
        GITHUB_TOKEN: ~e[secrets.GITHUB_TOKEN]
      ],
      on: ~w(pull_request push),
      jobs: [
        linux: job(:linux),
        windows: job(:windows),
        macos: job(:macos)
      ]
    ]
  end

  defp job(:linux = os) do
    job(os,
      name: """
      Test on #{Config.get([os, :name])} (\
      Elixir #{~e[matrix.elixir]}, \
      OTP #{~e[matrix.otp]})\
      """,
      runs_on: Config.get([os, :runs_on]),
      strategy: [
        matrix: Versions.matrix(elixir: Project.elixir(), otp: "> 20.0.0")
      ],
      steps: [
        checkout(),
        setup_elixir(os),
        restore(:deps),
        restore(:_build),
        restore(:dialyxir),
        get_deps(),
        compile_deps(os),
        compile(os),
        check_code_format(),
        lint_code(),
        run_tests(os),
        dialyxir()
      ]
    )
  end

  defp job(:windows = os) do
    job(os,
      name: "Test on #{Config.get([os, :name])}",
      runs_on: Config.get([os, :runs_on]),
      steps: [
        checkout(),
        restore(:chocolatey),
        setup_elixir(os),
        install_hex(),
        install_rebar(),
        get_deps(),
        compile_deps(os),
        compile(os),
        run_tests(os)
      ]
    )
  end

  defp job(:macos = os) do
    job(os,
      name: "Test on #{Config.get([os, :name])}",
      runs_on: Config.get([os, :runs_on]),
      steps: [
        checkout(),
        setup_elixir(os),
        install_hex(),
        install_rebar(),
        restore(:deps),
        restore(:_build),
        get_deps(),
        compile_deps(os),
        compile(os),
        run_tests(os)
      ]
    )
  end

  defp job(os, config) do
    case member?(:jobs, os) do
      true -> config
      false -> :skip
    end
  end

  defp checkout do
    [
      name: "Checkout",
      uses: "actions/checkout@v3"
    ]
  end

  defp setup_elixir(:linux) do
    [
      name: "Setup Elixir",
      uses: "erlef/setup-elixir@v1",
      with: [
        elixir_version: ~e[matrix.elixir],
        otp_version: ~e[matrix.otp]
      ]
    ]
  end

  defp setup_elixir(:macos) do
    [
      name: "Setup Elixir",
      run: "brew install elixir"
    ]
  end

  defp setup_elixir(:windows) do
    echo = ~S(echo "C:\ProgramData\chocolatey\lib\Elixir\bin;C:\ProgramData\chocolatey\bin")
    path = ~S(Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append)

    [
      name: "Setup Elixir",
      run: """
      cinst elixir --no-progress
      #{echo} | #{path}
      """
    ]
  end

  defp install_hex do
    [
      name: "Install hex",
      run: mix(:local, :hex, force: true)
    ]
  end

  defp install_rebar do
    [
      name: "Install rebar",
      run: mix(:local, :rebar, force: true)
    ]
  end

  defp restore(:chocolatey) do
    [
      name: "Restore chocolatey",
      uses: "actions/cache@v2",
      with: [
        path: ~S"C:\Users\runneradmin\AppData\Local\Temp\chocolatey",
        key: "#{~e[runner.os]}-chocolatey-#{~e[github.sha]}",
        restore_keys: """
        #{~e[runner.os]}-chocolatey-
        """
      ]
    ]
  end

  defp restore(:dialyxir) do
    case Project.has_dep?(:dialyxir) and Config.get([:steps, :dialyxir]) do
      false ->
        :skip

      true ->
        case Project.fetch([:dialyzer, :plt_file]) do
          :error ->
            :skip

          {:ok, {_, file}} ->
            file |> Path.dirname() |> restore()
        end
    end
  end

  defp restore(path) do
    case Config.fetch!([:steps, :refresh]) do
      false ->
        :skip

      true ->
        [
          name: "Restore #{path}",
          uses: "actions/cache@v2",
          with: [
            path: "#{path}",
            key: key(path)
          ]
        ]
    end
  end

  defp get_deps do
    [
      name: "Get dependencies",
      run: mix(:deps, :get)
    ]
  end

  defp compile_deps(os) do
    [
      name: "Compile dependencies",
      run: mix(:deps, :compile, env: :test, os: os)
    ]
  end

  defp compile(os) do
    [
      name: "Compile project",
      run: mix(:compile, warnings_as_errors: true, env: :test, os: os)
    ]
  end

  defp check_code_format do
    case Config.get(:check_code_format, true) do
      false ->
        :skip

      true ->
        [
          name: "Check code format",
          if: ~e"""
          contains(matrix.elixir, '#{Versions.latest(:elixir)}') && \
          contains(matrix.otp, '#{Versions.latest(:otp)}')\
          """,
          run: mix(:format, check_formatted: true, env: :test)
        ]
    end
  end

  defp lint_code do
    case Project.has_dep?(:credo) do
      false ->
        :skip

      true ->
        [
          name: "Lint code",
          if: ~e"""
          contains(matrix.elixir, '#{Versions.latest(:elixir)}') && \
          contains(matrix.otp, '#{Versions.latest(:otp)}')\
          """,
          run: mix(:credo, strict: true, env: :test)
        ]
    end
  end

  defp run_tests(:windows) do
    [
      name: "Run tests",
      run: mix(:test)
    ]
  end

  defp run_tests(_nix) do
    case Project.has_dep?(:excoveralls) do
      true ->
        [
          name: "Run tests with coverage",
          run: mix(:coveralls, Config.get([:steps, :coveralls]), env: :test)
        ]

      false ->
        [
          name: "Run tests",
          run: mix(:test)
        ]
    end
  end

  defp dialyxir do
    case Project.has_dep?(:dialyxir) do
      false ->
        :skip

      true ->
        [
          name: "Static code analysis",
          run: mix(:dialyzer)
        ]
    end
  end

  defp key(key) do
    os = ~e[runner.os]
    elixir = ~e[matrix.elixir]
    otp = ~e[matrix.otp]
    lock = ~e[hashFiles(format('{0}{1}', github.workspace, '/mix.lock'))]
    "#{key}-#{os}-#{elixir}-#{otp}-#{lock}"
  end

  defp member?(key, value), do: key |> Config.get() |> Enum.member?(value)
end
```
