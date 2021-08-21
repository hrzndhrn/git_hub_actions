defmodule GitHubActions.Project do
  @moduledoc """
  A thin wrapper for `Mix.Project` to access the `config`.
  """
  alias GitHubActions.Access

  @type key :: atom()
  @type keys :: [atom()]
  @type default :: any()
  @type value :: any()

  @doc """
  Returns the Elixir version of the current project.

  ## Examples

      iex> Project.elixir()
      "~> 1.10"
  """
  @spec elixir :: String.t()
  def elixir do
    fetch!(:elixir)
  end

  @doc """
  Returns `true` if the given `dep` is part of the project.

  ## Examples

      iex> Project.has_dep?(:credo)
      true

      iex> Project.has_dep?(:datix)
      false
  """
  @spec has_dep?(atom()) :: boolean()
  def has_dep?(dep) do
    Enum.any?(fetch!(:deps), fn
      {^dep, _requirement, _opts} -> true
      _dep -> false
    end)
  end

  @doc """
  Returns the value for given `keys` from the project config.

  ## Examples

      iex> Project.get(:app)
      :git_hub_actions

      iex> Project.get(:unknown, 42)
      42

      iex> Project.get([:test_coverage, :tool])
      ExCoveralls
  """
  @spec get(key() | keys(), default()) :: value()
  def get(keys, default \\ nil), do: Access.get(config(), keys, default)

  @doc """
  Returns the value for given `keys` from the project config, in a tuple.

  ## Examples

      iex> Project.fetch(:app)
      {:ok, :git_hub_actions}

      iex> Project.fetch(:unknown)
      :error

      iex> Project.fetch([:test_coverage, :tool])
      {:ok, ExCoveralls}
  """
  @spec fetch(key() | keys()) :: {:ok, value()} | :error
  def fetch(keys), do: Access.fetch(config(), keys)

  @doc """
  Returns the value for given `keys` from the project config, raises an error
  if `keys` are not available.

  ## Examples

      iex> Project.fetch!(:app)
      :git_hub_actions

      iex> Project.fetch!([:test_coverage, :tool])
      ExCoveralls
  """
  @spec fetch!(key() | keys()) :: value()
  def fetch!(keys), do: Access.fetch!(config(), keys)

  defdelegate config, to: Mix.Project
end
