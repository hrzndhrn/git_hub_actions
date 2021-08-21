defmodule GitHubActions.Sigils do
  @moduledoc """
  This module defnies the sigils for `GitHubActions`.
  """

  @doc """
  Handles the sigile `~e` for GitHub actions expressions.

  Quotes the given string as a GitHub expression.

  ## Examples

      iex> ~e[github.sha]
      "${{ github.sha }}"
  """
  @spec sigil_e(String.t(), list()) :: String.t()
  def sigil_e(string, _opts \\ []), do: String.replace("${{ #{string} }}", "\\\n", "")
end
