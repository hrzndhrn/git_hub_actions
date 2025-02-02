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
  def sigil_e(string, _opts), do: String.replace("${{ #{string} }}", "\\\n", "")

  @doc """
  Marks the given string as quoted.

  This sigil can be used to force quotes in the YAML output.

  ## Modifiers

    * `d`: forces a double quoted string (default)
    * `s`: forces a single quoted string
    * `e`: escapes newlines

  """
  @spec sigil_q(String.t(), list()) :: {:quoted, String.t()}
  def sigil_q(string, opts) do
    char =
      cond do
        ?d in opts -> ?"
        ?s in opts -> ?'
        true -> ?"
      end

    by = if ?e in opts, do: "\\\n", else: "\n"

    string =
      [char, string, char]
      |> IO.iodata_to_binary()
      |> String.replace("\\n", by)

    {:quoted, string}
  end
end
