defmodule Test.WorkflowSimple do
  use GitHubActions.Workflow

  def workflow do
    [
      name: "CI"
    ]
  end
end
