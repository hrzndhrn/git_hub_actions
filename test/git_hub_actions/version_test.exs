defmodule GitHubActions.VersionTest do
  use ExUnit.Case, async: true

  import Prove

  alias GitHubActions.Version

  doctest Version

  describe "parse/1" do
    batch "returns :ok tuple with version:" do
      prove Version.parse("1") == {:ok, %Version{major: 1, minor: nil, patch: nil}}

      prove Version.parse("1.2") == {:ok, %Version{major: 1, minor: 2, patch: nil}}

      prove Version.parse("1.2.3") == {:ok, %Version{major: 1, minor: 2, patch: 3}}

      prove Version.parse("foo") == :error

      prove Version.parse("1.foo") == :error

      prove Version.parse("1.2.3.4") == :error

      prove Version.parse("1.2.3-4") == :error

      prove Version.parse("") == :error
    end

    batch "returns :ok tuple with versions:" do
      prove Version.parse("1.0/2") ==
              {:ok,
               [
                 %Version{major: 1, minor: 0},
                 %Version{major: 1, minor: 1},
                 %Version{major: 1, minor: 2}
               ]}
    end
  end

  describe "parse!/1" do
    prove Version.parse!("1") == %Version{major: 1, minor: nil, patch: nil}

    prove Version.parse!("1.1") == %Version{major: 1, minor: 1, patch: nil}

    prove Version.parse!("123.123") == %Version{major: 123, minor: 123, patch: nil}

    prove Version.parse!("1.2.3") == %Version{major: 1, minor: 2, patch: 3}

    test "raises InvalidVersionError" do
      assert_raise GitHubActions.InvalidVersionError, ~s|invalid version: "foo"|, fn ->
        Version.parse!("foo")
      end
    end
  end

  describe "to_string/1" do
    prove to_string(Version.parse!("1")) == "1"

    prove to_string(Version.parse!("1.2")) == "1.2"

    prove to_string(Version.parse!("1.2.3")) == "1.2.3"
  end

  describe "compare/2" do
    prove Version.compare("1", "1") == :eq

    prove Version.compare("1", "1.0") == :eq

    prove Version.compare("1", "1.0.0") == :eq

    prove Version.compare("1.1", "1.1.0") == :eq

    prove Version.compare("1", "2") == :lt

    prove Version.compare("2", "1") == :gt

    prove Version.compare("2", "1.9") == :gt

    prove Version.compare("1.1", "1.0") == :gt

    prove Version.compare("1.1", "1.1") == :eq

    prove Version.compare("1.1", "1.2") == :lt

    prove Version.compare("1.5.1", "1.5.0") == :gt

    prove Version.compare("1.5.1", "1.5.1") == :eq

    prove Version.compare("1.5.1", "1.5.2") == :lt

    test "raises InvalidVersionError" do
      assert_raise GitHubActions.InvalidVersionError, ~s|invalid version: "foo"|, fn ->
        Version.compare("foo", "1")
      end
    end
  end

  describe "compare/3" do
    prove Version.compare("1.1.1", "1.1.2", :minor) == :eq

    prove Version.compare("1.1.1", "1.2.2", :minor) == :lt

    prove Version.compare("1.1.1", "1.0.2", :minor) == :gt

    prove Version.compare("2.1.1", "1.1.2", :minor) == :gt

    prove Version.compare("2.1.1", "3.1.2", :minor) == :lt

    prove Version.compare("1.1.1", "1.2.3", :major) == :eq
  end
end
