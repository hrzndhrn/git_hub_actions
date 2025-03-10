defmodule GitHubActions.YamlTest do
  use ExUnit.Case, async: true

  import Prove

  alias GitHubActions.Yaml

  prove Yaml.encode("foo") ==
          yaml("""
          foo
          """)

  prove Yaml.encode(1) ==
          yaml("""
          1
          """)

  prove Yaml.encode(["abc", "foo"]) ==
          yaml("""
          - abc
          - foo
          """)

  prove Yaml.encode(["abc", [1, "bar"], 2]) ==
          yaml("""
          - abc
          - - 1
            - bar
          - 2
          """)

  prove Yaml.encode(a: "abc", b: "foo\nbar", c: 5) ==
          yaml("""
          a: abc
          b: |
            foo
            bar
          c: 5
          """)

  prove Yaml.encode(a: [b: [c: "foo"]]) ==
          yaml("""
          a:
            b:
              c: foo
          """)

  prove Yaml.encode(a: [[x: 1, y: 2], [x: 3, y: 4]]) ==
          yaml("""
          a:
            - x: 1
              y: 2
            - x: 3
              y: 4
          """)

  prove Yaml.encode(a: ["a"], b: ["b"]) ==
          yaml("""
          a:
            - a
          b:
            - b
          """)

  prove Yaml.encode(a: %{b: "c\nd"}) ==
          yaml("""
          a:
            b: |
              c
              d
          """)

  defp yaml(string) do
    # will raise an error for invalid yaml document
    :yamerl.decode(string)
    string
  end
end
