defmodule Test.WorkflowMatrix do
  use GitHubActions.Workflow

  def workflow do
    [
      name: "CI",
      env: [
        GITHUB_TOKEN: ~e[secrets.GITHUB_TOKEN]
      ],
      jobs: [
        linux: linux()
      ]
    ]
  end

  defp linux do
    linux = Config.get([:linux, :name])
    elixir = ~e[matrix.elixir]
    otp = ~e[matrix.otp]

    [
      name: "Test on #{linux} (Elixir #{elixir}, OTP #{otp})",
      runs_on: Config.get([:linux, :runs_on]),
      strategy: matrix()
    ]
  end

  defp matrix do
    elixir =
      :elixir
      |> Versions.get()
      |> Versions.filter("~> 1.10")
      |> Versions.latest_minor()

    otp = :otp |> Versions.compatible_to(elixir: elixir) |> Versions.latest_major()

    exclude = Versions.incompatible(elixir: elixir, otp: otp)

    [
      matrix: [
        elixir: elixir,
        otp: otp,
        exclude: exclude
      ]
    ]
  end
end
