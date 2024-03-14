defmodule Test.WorkflowSteps do
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
      steps: [
        checkout(),
        foo()
      ]
    ]
  end

  defp checkout do
    [
      name: "Checkout",
      uses: "actions/checkout@v4"
    ]
  end

  defp foo, do: :skip
end
