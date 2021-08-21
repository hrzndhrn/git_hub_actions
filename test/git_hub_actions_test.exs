defmodule GitHubActionsTest do
  use GitHubActionsCase

  test "default" do
    file = "default.yml"

    local_config(output: [path: tmp(), file: file])

    assert_run(file)
  end

  test "missing --workflow" do
    assert_raise File.Error, fn ->
      GitHubActions.run(opts(workflow: "foo.exs"))
    end
  end

  test "missing default input" do
    local_config(input: [default: "foo.exs"])

    message = ~s|no workflow script found, sought: "foo.exs"|

    assert_raise GitHubActions.Error, message, fn ->
      GitHubActions.run(opts())
    end
  end

  test "invalid workflow script" do
    File.cp(fixture("workflow_invalid.exs"), local("default.exs"))

    message = ~s|invalid workflow script, script: ".gha/default.exs"|

    assert_raise GitHubActions.Error, message, fn ->
      GitHubActions.run(opts())
    end
  end
end
