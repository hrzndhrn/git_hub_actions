defmodule GitHubActions.Mix do
  @moduledoc """
  Some functions for handling mix commands in workflows.
  """

  alias GitHubActions.Config
  alias GitHubActions.ConvCase

  @doc """
  Generates a mix task.

  ## Examples

      iex> mix(:compile)
      "mix compile"
  """
  @spec mix(atom()) :: String.t()
  def mix(task) when is_atom(task) do
    mix(task, nil, [])
  end

  @doc ~S|
  Generates a mix task with a sub task or options.

  The options will be converted to comman line options.

  The "special" options `:env` and `:os` are used to set `MIX_ENV`.

  ## Examples

      iex> mix(:deps, :compile)
      "mix deps.compile"

      iex> mix(:credo, strict: true)
      "mix credo --strict"

      iex> mix(:credo, strict: false)
      "mix credo"

      iex> mix(:sample, arg: 42)
      "mix sample --arg 42"

      iex> mix(:compile, env: :test)
      "MIX_ENV=test mix compile"

      iex> mix(:compile, env: :test, os: :windows)
      "set MIX_ENV=test\nmix compile\n"

      iex> mix(:compile, os: :windows)
      "mix compile"
  |
  @spec mix(atom(), atom() | keyword()) :: String.t()
  def mix(task, sub_task_or_opts) when is_atom(task) and is_list(sub_task_or_opts) do
    mix(task, nil, sub_task_or_opts)
  end

  def mix(task, sub_task_or_opts) when is_atom(task) and is_atom(sub_task_or_opts) do
    mix(task, sub_task_or_opts, [])
  end

  @doc """
  Generates a mix task with a sub task or options.

  ## Examples

      iex> mix(:deps, :compile, warnings_as_errors: true)
      "mix deps.compile --warnings-as-errors"
  """
  def mix(task, sub_task, opts)
      when is_atom(task) and is_atom(sub_task) and is_list(opts) do
    {os, opts} = Keyword.pop(opts, :os)
    {env, opts} = Keyword.pop(opts, :env)

    case {os, env(env)} do
      {:windows, nil} ->
        "mix #{task(task, sub_task)}#{args(opts)}"

      {:windows, env} ->
        """
        set #{env}
        mix #{task(task, sub_task)}#{args(opts)}
        """

      {_nix, nil} ->
        "mix #{task(task, sub_task)}#{args(opts)}"

      {_nix, env} ->
        "#{env} mix #{task(task, sub_task)}#{args(opts)}"
    end
  end

  defp task(task, nil), do: "#{task}"

  defp task(task, sub_task), do: "#{task}.#{sub_task}"

  defp args(opts) do
    opts
    |> Enum.reduce([], fn
      {key, true}, acc ->
        ["--#{to_kebab_case(key)}" | acc]

      {_key, false}, acc ->
        acc

      {key, value}, acc ->
        ["--#{to_kebab_case(key)} #{to_string(value)}" | acc]
    end)
    |> Enum.join(" ")
    |> case do
      "" -> ""
      string -> " #{string}"
    end
  end

  defp to_kebab_case(value) do
    value |> to_string() |> ConvCase.to_kebab()
  end

  defp env(target) do
    case Config.get([:mix, :env]) || target do
      nil -> nil
      target -> "MIX_ENV=#{target}"
    end
  end
end
