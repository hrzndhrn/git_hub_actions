defmodule GitHubActions.ConvCase do
  @moduledoc false

  def to_kebab(atom) when is_atom(atom) do
    atom
    |> to_string()
    |> to_kebab()
    |> String.to_atom()
  end

  def to_kebab(string) when is_binary(string) do
    case env_var?(string) do
      true ->
        string

      false ->
        nil
        String.replace(string, "_", "-")
    end
  end

  defp env_var?(string) when is_binary(string) do
    Regex.match?(~r/^[A-Z]+[A-Z0-9_]*$/, string)
  end
end
