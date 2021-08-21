defmodule Mix.Tasks.GhaTest do
  use GitHubActionsCase

  test "default" do
    file = "default.yml"

    local_config(output: [path: tmp(), file: file])

    assert_run(file)
  end

  test "default with global config" do
    file = "global_default.yml"

    global_config(output: [path: tmp(), file: file])

    assert_run(file)
  end

  test "without comment" do
    file = "no_comment.yml"

    local_config(output: [path: tmp(), file: file, comment: false])

    assert_run(file)
  end

  test "windows" do
    file = "windows.yml"

    local_config(output: [path: tmp(), file: file, comment: false], jobs: [:windows])

    assert_run(file)
  end

  test "macos" do
    file = "macos.yml"

    local_config(output: [path: tmp(), file: file, comment: false], jobs: [:macos])

    assert_run(file)
  end

  test "with --output" do
    file = "opt_output.yml"

    local_config(output: [comment: true])

    assert_run(file, ["--output", Path.join(tmp(), file)])
  end

  test "with -o" do
    file = "opt_output.yml"

    local_config(output: [comment: true])

    assert_run(file, ["-o", Path.join(tmp(), file)])
  end

  test "with --workflow" do
    file = "opt_workflow.yml"

    local_config(output: [path: tmp(), file: file])

    assert_run(file, ["--workflow", "test/fixtures/workflow_simple.exs"])
  end

  test "with -w" do
    file = "opt_workflow.yml"

    local_config(output: [path: tmp(), file: file])

    assert_run(file, ["-w", "test/fixtures/workflow_simple.exs"])
  end

  test "with --config" do
    file = "opt_config.yml"

    local_config(output: [path: tmp(), file: file])

    assert_run(file, [
      "--workflow",
      "test/fixtures/workflow_simple.exs",
      "--config",
      "test/fixtures/no_comment.exs"
    ])
  end
end
