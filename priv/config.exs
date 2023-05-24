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
  runs_on: "ubuntu-20.04"

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
             "1.12.0/3",
             "1.13.0/4"
           ]
         ],
         [
           otp: ["23.0/3"],
           elixir: [
             "1.10.3/4",
             "1.11.0/4",
             "1.12.0/3",
             "1.13.0/4",
             "1.14.0/5"
           ]
         ],
         [
           otp: ["24.0/3"],
           elixir: [
             "1.11.4",
             "1.12.0/3",
             "1.13.0/4",
             "1.14.0/5"
           ]
         ],
         [
           otp: ["25.0/3"],
           elixir: [
             "1.13.4",
             "1.14.0/5"
           ]
         ],
         [
           otp: ["26.0"],
           elixir: [
             "1.14.5"
           ]
         ]
       ]
