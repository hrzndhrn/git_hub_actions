defmodule GitHubActions.VersionsTest do
  use ExUnit.Case

  import Prove

  alias GitHubActions.Config
  alias GitHubActions.Version
  alias GitHubActions.Versions

  doctest Versions

  :ok = Config.read("priv/config.exs")
  @versions Config.fetch!(:versions)

  setup do
    Config.read("priv/config.exs")
    :ok
  end

  test "from_config/0" do
    assert List.last(Versions.from_config()) ==
             [otp: ["27.0/2"], elixir: ["1.17.0/3", "1.18.0"]]
  end

  describe "get/2" do
    test "all elixir versions" do
      assert @versions |> Versions.get(:elixir) |> Enum.map(&to_string/1) == [
               # v1.0.0/5
               "1.0.0",
               "1.0.1",
               "1.0.2",
               "1.0.3",
               "1.0.4",
               "1.0.5",
               # v1.1.0/1
               "1.1.0",
               "1.1.1",
               # v1.2.0/6
               "1.2.0",
               "1.2.1",
               "1.2.2",
               "1.2.3",
               "1.2.4",
               "1.2.5",
               "1.2.6",
               # v1.3.0/4
               "1.3.0",
               "1.3.1",
               "1.3.2",
               "1.3.3",
               "1.3.4",
               # v1.4.0/5
               "1.4.0",
               "1.4.1",
               "1.4.2",
               "1.4.3",
               "1.4.4",
               "1.4.5",
               # v1.5.0/3
               "1.5.0",
               "1.5.1",
               "1.5.2",
               "1.5.3",
               # v1.6.0/6
               "1.6.0",
               "1.6.1",
               "1.6.2",
               "1.6.3",
               "1.6.4",
               "1.6.5",
               "1.6.6",
               # v1.7.0/4
               "1.7.0",
               "1.7.1",
               "1.7.2",
               "1.7.3",
               "1.7.4",
               # v1.8.0/2
               "1.8.0",
               "1.8.1",
               "1.8.2",
               # v1.9.0/4
               "1.9.0",
               "1.9.1",
               "1.9.2",
               "1.9.3",
               "1.9.4",
               # v1.10.0/4
               "1.10.0",
               "1.10.1",
               "1.10.2",
               "1.10.3",
               "1.10.4",
               # v1.11.0/4
               "1.11.0",
               "1.11.1",
               "1.11.2",
               "1.11.3",
               "1.11.4",
               # v1.12.0/3
               "1.12.0",
               "1.12.1",
               "1.12.2",
               "1.12.3",
               # v1.13.0/4
               "1.13.0",
               "1.13.1",
               "1.13.2",
               "1.13.3",
               "1.13.4",
               # v1.14.0/3
               "1.14.0",
               "1.14.1",
               "1.14.2",
               "1.14.3",
               "1.14.4",
               "1.14.5",
               # v1.15.0/8
               "1.15.0",
               "1.15.1",
               "1.15.2",
               "1.15.3",
               "1.15.4",
               "1.15.5",
               "1.15.6",
               "1.15.7",
               "1.15.8",
               # v1.16.0/3
               "1.16.0",
               "1.16.1",
               "1.16.2",
               "1.16.3",
               # v1.17.0/3
               "1.17.0",
               "1.17.1",
               "1.17.2",
               "1.17.3",
               # v1.18.0
               "1.18.0"
             ]
    end

    test "get all otp versions" do
      assert @versions |> Versions.get(:otp) |> Enum.map(&to_string/1) ==
               [
                 "17.0",
                 "17.1",
                 "17.2",
                 "17.3",
                 "17.4",
                 "17.5",
                 "18.0",
                 "18.1",
                 "18.2",
                 "18.3",
                 "19.0",
                 "19.1",
                 "19.2",
                 "19.3",
                 "20.0",
                 "20.1",
                 "20.2",
                 "20.3",
                 "21.0",
                 "21.1",
                 "21.2",
                 "21.3",
                 "22.0",
                 "22.1",
                 "22.2",
                 "22.3",
                 "23.0",
                 "23.1",
                 "23.2",
                 "23.3",
                 "24.0",
                 "24.1",
                 "24.2",
                 "24.3",
                 "25.0",
                 "25.1",
                 "25.2",
                 "25.3",
                 "26.0",
                 "26.1",
                 "26.2",
                 "27.0",
                 "27.1",
                 "27.2"
               ]
    end
  end

  describe "expand/1" do
    test "list of versions" do
      list = ["1", "2.0/2", "2.3.0/1"]

      assert Versions.expand(list) == [
               %Version{major: 1},
               %Version{major: 2, minor: 0},
               %Version{major: 2, minor: 1},
               %Version{major: 2, minor: 2},
               %Version{major: 2, minor: 3, patch: 0},
               %Version{major: 2, minor: 3, patch: 1}
             ]
    end

    test "table of versions" do
      table = [
        [a: ["2.0/2"], b: ["1.3", "2.0/1"]],
        [a: ["1.0.0"], b: ["1.0/2"]]
      ]

      assert Versions.expand(table) == [
               [
                 a: [
                   %Version{major: 1, minor: 0, patch: 0}
                 ],
                 b: [
                   %Version{major: 1, minor: 0},
                   %Version{major: 1, minor: 1},
                   %Version{major: 1, minor: 2}
                 ]
               ],
               [
                 a: [
                   %Version{major: 2, minor: 0},
                   %Version{major: 2, minor: 1},
                   %Version{major: 2, minor: 2}
                 ],
                 b: [
                   %Version{major: 1, minor: 3},
                   %Version{major: 2, minor: 0},
                   %Version{major: 2, minor: 1}
                 ]
               ]
             ]
    end
  end

  describe "latest/2" do
    test "from a table of versions" do
      table = [
        [a: ["2.0/2"], b: ["1.3", "2.0.0/5"]],
        [a: ["1.0.0"], b: ["1.0/2"]]
      ]

      assert Versions.latest(table, :a) == %Version{major: 2, minor: 2}
      assert Versions.latest(table, :b) == %Version{major: 2, minor: 0, patch: 5}
    end
  end

  describe "filter/2" do
    test "elixir versions" do
      assert @versions |> Versions.get(:elixir) |> Versions.filter("~> 1.11") == [
               %Version{major: 1, minor: 11, patch: 0},
               %Version{major: 1, minor: 11, patch: 1},
               %Version{major: 1, minor: 11, patch: 2},
               %Version{major: 1, minor: 11, patch: 3},
               %Version{major: 1, minor: 11, patch: 4},
               %Version{major: 1, minor: 12, patch: 0},
               %Version{major: 1, minor: 12, patch: 1},
               %Version{major: 1, minor: 12, patch: 2},
               %Version{major: 1, minor: 12, patch: 3},
               %Version{major: 1, minor: 13, patch: 0},
               %Version{major: 1, minor: 13, patch: 1},
               %Version{major: 1, minor: 13, patch: 2},
               %Version{major: 1, minor: 13, patch: 3},
               %Version{major: 1, minor: 13, patch: 4},
               %Version{major: 1, minor: 14, patch: 0},
               %Version{major: 1, minor: 14, patch: 1},
               %Version{major: 1, minor: 14, patch: 2},
               %Version{major: 1, minor: 14, patch: 3},
               %Version{major: 1, minor: 14, patch: 4},
               %Version{major: 1, minor: 14, patch: 5},
               %Version{major: 1, minor: 15, patch: 0},
               %Version{major: 1, minor: 15, patch: 1},
               %Version{major: 1, minor: 15, patch: 2},
               %Version{major: 1, minor: 15, patch: 3},
               %Version{major: 1, minor: 15, patch: 4},
               %Version{major: 1, minor: 15, patch: 5},
               %Version{major: 1, minor: 15, patch: 6},
               %Version{major: 1, minor: 15, patch: 7},
               %Version{major: 1, minor: 15, patch: 8},
               %Version{major: 1, minor: 16, patch: 0},
               %Version{major: 1, minor: 16, patch: 1},
               %Version{major: 1, minor: 16, patch: 2},
               %Version{major: 1, minor: 16, patch: 3},
               %Version{major: 1, minor: 17, patch: 0},
               %Version{major: 1, minor: 17, patch: 1},
               %Version{major: 1, minor: 17, patch: 2},
               %Version{major: 1, minor: 17, patch: 3},
               %Version{major: 1, minor: 18, patch: 0}
             ]
    end

    test "empty list" do
      assert Versions.filter([], "> 1.0.0") == []
    end

    test "with invalid requirement" do
      assert Versions.filter([], "> 1") == []

      assert_raise Elixir.Version.InvalidRequirementError, fn ->
        Versions.filter(["1"], "> 1")
      end
    end
  end

  describe "latest_minor/2" do
    test "from a table of versions" do
      assert Versions.latest_minor(@versions, :elixir) == [
               %Version{major: 1, minor: 0, patch: 5},
               %Version{major: 1, minor: 1, patch: 1},
               %Version{major: 1, minor: 2, patch: 6},
               %Version{major: 1, minor: 3, patch: 4},
               %Version{major: 1, minor: 4, patch: 5},
               %Version{major: 1, minor: 5, patch: 3},
               %Version{major: 1, minor: 6, patch: 6},
               %Version{major: 1, minor: 7, patch: 4},
               %Version{major: 1, minor: 8, patch: 2},
               %Version{major: 1, minor: 9, patch: 4},
               %Version{major: 1, minor: 10, patch: 4},
               %Version{major: 1, minor: 11, patch: 4},
               %Version{major: 1, minor: 12, patch: 3},
               %Version{major: 1, minor: 13, patch: 4},
               %Version{major: 1, minor: 14, patch: 5},
               %Version{major: 1, minor: 15, patch: 8},
               %Version{major: 1, minor: 16, patch: 3},
               %Version{major: 1, minor: 17, patch: 3},
               %Version{major: 1, minor: 18, patch: 0}
             ]
    end
  end

  describe "latest_major/2" do
    test "from a table of versions" do
      assert Versions.latest_major(@versions, :otp) == [
               %Version{major: 17, minor: 5},
               %Version{major: 18, minor: 3},
               %Version{major: 19, minor: 3},
               %Version{major: 20, minor: 3},
               %Version{major: 21, minor: 3},
               %Version{major: 22, minor: 3},
               %Version{major: 23, minor: 3},
               %Version{major: 24, minor: 3},
               %Version{major: 25, minor: 3},
               %Version{major: 26, minor: 2},
               %Version{major: 27, minor: 2}
             ]
    end
  end

  describe "compatible/3" do
    test "otp versions" do
      otp = [
        %Version{major: 21, minor: 0},
        %Version{major: 21, minor: 1},
        %Version{major: 21, minor: 2},
        %Version{major: 21, minor: 3},
        %Version{major: 22, minor: 0},
        %Version{major: 22, minor: 1},
        %Version{major: 22, minor: 2},
        %Version{major: 22, minor: 3},
        %Version{major: 23, minor: 0},
        %Version{major: 23, minor: 1},
        %Version{major: 23, minor: 2},
        %Version{major: 23, minor: 3}
      ]

      assert Versions.compatible(@versions, :otp, elixir: "1.11") == otp

      assert Versions.compatible(@versions, :otp, elixir: "1.11.4") ==
               otp ++
                 [
                   %Version{major: 24, minor: 0},
                   %Version{major: 24, minor: 1},
                   %Version{major: 24, minor: 2},
                   %Version{major: 24, minor: 3}
                 ]
    end

    test "otp versions for multiple elixir versions" do
      assert Versions.compatible(@versions, :otp, elixir: "1.11.0/4") == [
               %Version{major: 21, minor: 0},
               %Version{major: 21, minor: 1},
               %Version{major: 21, minor: 2},
               %Version{major: 21, minor: 3},
               %Version{major: 22, minor: 0},
               %Version{major: 22, minor: 1},
               %Version{major: 22, minor: 2},
               %Version{major: 22, minor: 3},
               %Version{major: 23, minor: 0},
               %Version{major: 23, minor: 1},
               %Version{major: 23, minor: 2},
               %Version{major: 23, minor: 3},
               %Version{major: 24, minor: 0},
               %Version{major: 24, minor: 1},
               %Version{major: 24, minor: 2},
               %Version{major: 24, minor: 3}
             ]
    end

    test "raises error for invalid versions" do
      message = "compatible/3 expected a table of versions as first argument, got: [:a]"

      assert_raise ArgumentError, message, fn ->
        Versions.compatible([:a], :a, b: "1")
      end
    end

    test "raises error for invalid version" do
      message = "compatible/3 expected a list of versions for :elixir, got: [:a]"

      assert_raise ArgumentError, message, fn ->
        Versions.compatible(@versions, :otp, elixir: [:a])
      end
    end
  end

  describe "compatible?/3" do
    batch "returns true for compatible version" do
      prove Versions.compatible?(@versions, elixir: "1.11.4", otp: "21.3") == true
      prove Versions.compatible?(@versions, elixir: "1.12", otp: "24.3") == true
    end

    batch "returns false for incompatible version" do
      prove Versions.compatible?(@versions, elixir: "1.11.4", otp: "19.0") == false
      prove Versions.compatible?(@versions, elixir: "1.6", otp: "24.3") == false
    end
  end

  describe "incompatible/3" do
    test "from otp and elixir versions" do
      elixir =
        @versions
        |> Versions.get(:elixir)
        |> Versions.filter("~> 1.12")
        |> Versions.latest_minor()

      otp = @versions |> Versions.compatible(:otp, elixir: elixir) |> Versions.latest_major()

      assert Versions.incompatible(@versions, otp: otp, elixir: elixir) == [
               [
                 otp: %Version{major: 22, minor: 3},
                 elixir: %Version{major: 1, minor: 14, patch: 5}
               ],
               [
                 otp: %Version{major: 22, minor: 3},
                 elixir: %Version{major: 1, minor: 15, patch: 8}
               ],
               [
                 otp: %Version{major: 22, minor: 3},
                 elixir: %Version{major: 1, minor: 16, patch: 3}
               ],
               [
                 otp: %Version{major: 22, minor: 3},
                 elixir: %Version{major: 1, minor: 17, patch: 3}
               ],
               [
                 otp: %Version{major: 22, minor: 3},
                 elixir: %Version{major: 1, minor: 18, patch: 0}
               ],
               [
                 otp: %Version{major: 23, minor: 3},
                 elixir: %Version{major: 1, minor: 15, patch: 8}
               ],
               [
                 otp: %Version{major: 23, minor: 3},
                 elixir: %Version{major: 1, minor: 16, patch: 3}
               ],
               [
                 otp: %Version{major: 23, minor: 3},
                 elixir: %Version{major: 1, minor: 17, patch: 3}
               ],
               [
                 otp: %Version{major: 23, minor: 3},
                 elixir: %Version{major: 1, minor: 18, patch: 0}
               ],
               [
                 otp: %Version{major: 24, minor: 3},
                 elixir: %Version{major: 1, minor: 17, patch: 3}
               ],
               [
                 otp: %Version{major: 24, minor: 3},
                 elixir: %Version{major: 1, minor: 18, patch: 0}
               ],
               [
                 otp: %Version{major: 25, minor: 3},
                 elixir: %Version{major: 1, minor: 12, patch: 3}
               ],
               [
                 otp: %Version{major: 26, minor: 2},
                 elixir: %Version{major: 1, minor: 12, patch: 3}
               ],
               [
                 otp: %Version{major: 26, minor: 2},
                 elixir: %Version{major: 1, minor: 13, patch: 4}
               ],
               [
                 otp: %Version{major: 27, minor: 2},
                 elixir: %Version{major: 1, minor: 12, patch: 3}
               ],
               [
                 otp: %Version{major: 27, minor: 2},
                 elixir: %Version{major: 1, minor: 13, patch: 4}
               ],
               [
                 otp: %Version{major: 27, minor: 2},
                 elixir: %Version{major: 1, minor: 14, patch: 5}
               ],
               [
                 otp: %Version{major: 27, minor: 2},
                 elixir: %Version{major: 1, minor: 15, patch: 8}
               ],
               [
                 otp: %Version{major: 27, minor: 2},
                 elixir: %Version{major: 1, minor: 16, patch: 3}
               ]
             ]
    end

    test "raises error for invalid versions" do
      message = "incompatible/2 expected a table of versions as first argument, got: []"

      assert_raise ArgumentError, message, fn ->
        Versions.incompatible([], a: "1", b: "2")
      end
    end

    test "raises error for invalid version lists" do
      versions = [
        [a: ["1"], b: ["1"]],
        [a: ["2"], b: ["2"]]
      ]

      message = "incompatible/2 expected a list of versions for :a, got: [:foo]"

      assert_raise ArgumentError, message, fn ->
        Versions.incompatible(versions, a: [:foo], b: "1")
      end

      assert_raise ArgumentError, message, fn ->
        Versions.incompatible(versions, b: ["1"], a: [:foo])
      end
    end
  end

  describe "sort/1" do
    test "table of versions" do
      assert Versions.sort([
               [a: ["3"], b: ["2.1", "2.0"]],
               [a: ["2", "1"], b: ["1.1", "1.0"]]
             ]) == [
               [
                 a: [%Version{major: 1}, %Version{major: 2}],
                 b: [%Version{major: 1, minor: 0}, %Version{major: 1, minor: 1}]
               ],
               [
                 a: [%Version{major: 3}],
                 b: [%Version{major: 2, minor: 0}, %Version{major: 2, minor: 1}]
               ]
             ]
    end
  end

  describe "matrix/2" do
    test "create matrix for elixir requirement '> 1.10'" do
      assert Versions.matrix(elixir: ">= 1.10.0 and < 1.13.3", otp: ">= 20.0.0 and < 24.0.0") == [
               elixir: [
                 Version.parse!("1.10.4"),
                 Version.parse!("1.11.4"),
                 Version.parse!("1.12.3"),
                 Version.parse!("1.13.2")
               ],
               otp: [
                 Version.parse!("21.3"),
                 Version.parse!("22.3"),
                 Version.parse!("23.3")
               ],
               exclude: [
                 [elixir: Version.parse!("1.12.3"), otp: Version.parse!("21.3")],
                 [elixir: Version.parse!("1.13.2"), otp: Version.parse!("21.3")]
               ]
             ]
    end

    test "create matrix for elixir requirement '== 1.13.3'" do
      assert Versions.matrix(elixir: "== 1.13.3", otp: "== 23.0.0") == [
               elixir: [Version.parse!("1.13.3")],
               otp: [Version.parse!("23.0")]
             ]
    end
  end
end
