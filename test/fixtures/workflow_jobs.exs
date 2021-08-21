defmodule Test.WorkflowJobs do
  use GitHubActions.Workflow

  def workflow do
    [
      name: "CI",
      env: [
        GITHUB_TOKEN: ~e[secrets.GITHUB_TOKEN]
      ],
      jobs: [
        linux: linux(),
        # `:foo` will be skipped
        foo: :skip
      ]
    ]
  end

  defp linux do
    linux = Config.fetch!([:linux, :name])
    elixir = ~e[matrix.elixir]
    otp = ~e[matrix.otp]

    [
      name: "Test on #{linux} (Elixir #{elixir}, OTP #{otp})",
      runs_on: Config.fetch!([:linux, :runs_on])
    ]
  end
end
