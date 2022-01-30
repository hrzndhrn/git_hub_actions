# credo:disable-for-this-file
# Reactivate when credo version > 1.6.2 is released.
defmodule GitHubActions.SigilsTest do
  use ExUnit.Case

  import GitHubActions.Sigils

  doctest GitHubActions.Sigils

  test "multiline" do
    assert ~e"""
           one
           two
           """ == "${{ one\ntwo\n }}"

    assert ~e"""
           one \
           two\
           """ == "${{ one two }}"
  end
end
