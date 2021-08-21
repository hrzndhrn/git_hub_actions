defmodule GitHubActions.Workflow.MixTest do
  use ExUnit.Case

  alias GitHubActions.Config

  import GitHubActions.Mix

  doctest GitHubActions.Mix

  setup do
    Config.read("priv/config.exs")
    :ok
  end
end
