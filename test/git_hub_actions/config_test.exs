defmodule GitHubActions.ConfigTest do
  use ExUnit.Case, async: true

  import Prove

  alias GitHubActions.Config

  doctest Config

  setup do
    Config.read("priv/config.exs")
    :ok
  end

  describe "read/1" do
    test "raises error" do
      assert_raise File.Error, fn ->
        Config.read("config/not/exists.exs")
      end
    end

    test "overwrites values" do
      Config.read("test/fixtures/no_comment.exs")

      assert Config.fetch!(:output) == [path: ".github/workflows", file: "ci.yml", comment: false]
    end
  end

  describe "get/2" do
    prove Config.get(:output) == [comment: true, path: ".github/workflows", file: "ci.yml"]
    prove Config.get([:output, :file]) == "ci.yml"
    prove Config.get(:foo) == nil
    prove Config.get(:foo, :default) == :default
    prove Config.get([:foo, :bar]) == nil
    prove Config.get([:foo, :bar], :default) == :default
  end

  describe "fetch/1" do
    prove Config.fetch(:output) ==
            {:ok, [comment: true, path: ".github/workflows", file: "ci.yml"]}

    prove Config.fetch([:output, :file]) == {:ok, "ci.yml"}
    prove Config.fetch(:foo) == :error
    prove Config.fetch([:output, :foo]) == :error
  end

  describe "fetch!/1" do
    prove Config.fetch!(:output) == [comment: true, path: ".github/workflows", file: "ci.yml"]
    prove Config.fetch!([:output, :file]) == "ci.yml"

    test "raises error" do
      assert_raise KeyError, fn ->
        Config.fetch!([:output, :foo])
      end
    end
  end

  describe "config/1" do
    test "raises an error" do
      message = "config/1 expected a keyword list, got: #{inspect(~c"*")}"

      assert_raise ArgumentError, message, fn -> Config.config([42]) end
    end
  end
end
