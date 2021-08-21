defmodule GitHubActions.Config do
  @moduledoc """
  A simple keyword-based configuration API.

  ## Examples

  This module is used to define the configuration for `GitHubActions`.

  ```elixir
  import GitHubActions.Config

  config :linux,
    name: "Ubuntu",
    runs_on: "ubuntu-latest"

  config key: "value"
  """

  alias GitHubActions.Access

  @config_key __MODULE__

  @type key :: atom()
  @type keys :: [atom()]
  @type value :: any()
  @type config :: keyword()

  @doc """
  Reads the configuration from the given `path`.
  """
  @spec read(Path.t()) :: :ok | {:error, :enonet}
  def read(path) do
    path |> File.read!() |> Code.eval_string()
    :ok
  end

  @doc """
  Returns the configuaration.
  """
  @spec config :: config()
  def config, do: Process.get(@config_key) || []

  @doc """
  Adds the given `value` to the configuration under the given `key`.

  Returns the configuration that was previously stored.
  """
  @spec config(key(), value()) :: config() | nil
  def config(key, value) when is_atom(key), do: add([{key, value}])

  @doc """
  Adds the given data to the configuration.

  Returns the configuration that was previously stored.
  """
  @spec config(config()) :: config() | nil
  def config(data) when is_list(data) do
    unless Keyword.keyword?(data) do
      raise ArgumentError, "config/1 expected a keyword list, got: #{inspect(data)}"
    end

    add(data)
  end

  @doc """
  Returns the value for `key` or `keys`.

  If the configuration parameter does not exist, the function returns the
  default value.

  ## Examples

      iex> Config.get(:jobs)
      [:linux]

      iex> Config.get(:foo, :bar)
      :bar

      iex> Config.get([:linux, :runs_on])
      "ubuntu-latest"

      iex> Config.get(:foo)
      nil
  """
  @spec get(key() | keys(), value()) :: value()
  def get(keys, default \\ nil), do: Access.get(config!(), keys, default)

  @doc """
  Returns the value for `key` or `keys` in a tuple.

  If the configuration parameter does not exist, the function returns `error`.

  ## Examples

      iex> Config.fetch(:jobs)
      {:ok, [:linux]}

      iex> Config.fetch(:foo)
      :error

      iex> Config.fetch([:linux, :name])
      {:ok, "Ubuntu"}
  """
  @spec fetch(key() | keys()) :: value()
  def fetch(keys), do: Access.fetch(config!(), keys)

  @doc """
  Returns the value for `key` or `keys`.

  ## Examples

      iex> Config.fetch!(:jobs)
      [:linux]

      iex> Config.fetch!([:linux, :runs_on])
      "ubuntu-latest"

      iex> Config.fetch!([:linux, :foo])
      ** (KeyError) key :foo not found in: [name: \"Ubuntu\", runs_on: \"ubuntu-latest\"]
  """
  def fetch!(keys), do: Access.fetch!(config!(), keys)

  defp add([{key, value}] = data) when is_atom(key) and is_list(value) do
    case Keyword.keyword?(value) do
      true ->
        merge(key, config(), value) |> put()

      false ->
        config() |> Keyword.merge(data) |> put()
    end
  end

  defp add(data), do: config() |> Keyword.merge(data) |> put

  defp merge(key, config, data) do
    new = config |> Keyword.get(key, []) |> Keyword.merge(data)
    Keyword.put(config, key, new)
  end

  defp put(value), do: Process.put(@config_key, value)

  defp config!, do: Process.get(@config_key) || raise("No configuration available")
end
