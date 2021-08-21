defmodule GitHubActions.Yaml do
  @moduledoc false

  @spec encode(any()) :: String.t()
  def encode(data) do
    data
    |> do_encode([], 0)
    |> Enum.reverse()
    |> Enum.join("\n")
    |> newline()
  end

  defp do_encode(data, lines, _depth) when is_binary(data) do
    string = if num_or_version?(data), do: "'#{data}'", else: data

    [string | lines]
  end

  defp do_encode(data, lines, _depth) when is_number(data) do
    [to_string(data) | lines]
  end

  defp do_encode(data, lines, depth) when is_map(data) do
    data
    |> Enum.into([])
    |> do_encode(lines, depth)
  end

  defp do_encode([{key, item} | data], lines, depth) when is_binary(item) do
    item = if num_or_version?(item), do: "'#{item}'", else: item

    case lines?(item) do
      true ->
        add = indent_heredoc(key, item, depth)
        do_encode(data, add ++ lines, depth)

      false ->
        add = indent_key(key, item, depth)
        do_encode(data, [add | lines], depth)
    end
  end

  defp do_encode([{key, item} | data], lines, depth) when is_number(item) do
    add = indent_key(key, item, depth)
    do_encode(data, [add | lines], depth)
  end

  defp do_encode([{key, item} | data], lines, depth) do
    add = indent_key(key, depth)
    sub = do_encode(item, [], depth + 1)
    do_encode(data, Enum.concat([sub, [add], lines]), depth)
  end

  defp do_encode([item | data], lines, depth) do
    {items, [last]} = do_encode(item, [], 0) |> Enum.split(-1)
    items = indent(items, depth + 1) ++ [indent_item(last, depth)]
    do_encode(data, items ++ lines, depth)
  end

  defp do_encode([], lines, _depth), do: lines

  defp indent(depth), do: String.duplicate(" ", depth * 2)

  defp indent(lines, depth) when is_list(lines) do
    Enum.map(lines, fn line -> "#{indent(depth)}#{line}" end)
  end

  defp indent_item(item, depth), do: "#{indent(depth)}- #{item}"

  defp indent_key(key, depth), do: "#{indent(depth)}#{key}:"

  defp indent_heredoc(string, depth) do
    string
    |> String.trim_trailing()
    |> String.split("\n")
    |> indent(depth)
    |> Enum.reverse()
  end

  defp indent_key(key, item, depth), do: "#{indent_key(key, depth)} #{item}"

  defp indent_heredoc(key, string, depth) do
    lines = indent_heredoc(string, depth + 1)
    line = "#{indent_key(key, depth)} |"
    lines ++ [line]
  end

  defp lines?(string), do: String.contains?(string, "\n")

  defp newline(string), do: "#{string}\n"

  defp num_or_version?(string) do
    string
    |> String.split(".")
    |> Enum.all?(fn part -> part =~ ~r/^\d+$/ end)
  end
end
