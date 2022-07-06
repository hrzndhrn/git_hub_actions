defmodule GitHubActions.Version do
  @moduledoc """
  Functions for parsing and matching versions against requirements.

  A version is a string in a specific format or a `GitHubActions.Version` generated after
  parsing via `GitHubActions.Version.parse/1`.

  This module is similar to `Version` except that `minor` and `patch` may be missing
  and `pre` are not supported.

  The Version module can also parse a range of versions.

  ## Examples

      iex> "2.0/2" |> Version.parse!() |> Enum.map(&to_string/1)
      ["2.0", "2.1", "2.2"]

      iex> "1/3" |> Version.parse!() |> Enum.map(&to_string/1)
      ["1", "2", "3"]
  """

  import Kernel, except: [match?: 2]

  alias Elixir.Version.Requirement

  @separator "."
  @range "/"
  @requirement_operators [
    ">=",
    "<=",
    "~>",
    ">",
    "<",
    "==",
    "!=",
    "!"
  ]
  @fields [:major, :minor, :patch]

  defstruct @fields

  @type version :: String.t() | t
  @type major :: non_neg_integer | nil
  @type minor :: non_neg_integer | nil
  @type patch :: non_neg_integer | nil
  @type t :: %__MODULE__{major: major, minor: minor, patch: patch}
  @type requirement :: String.t() | Requirement.t()

  @doc """
  Parses a version string into a `GitHubActions.Version` struct.

  ## Examples

      iex> {:ok, version} = Version.parse("1.2")
      iex> version
      #Version<1.2>

      iex> Version.parse("1-2")
      :error

      iex> {:ok, [v1, v2, v3]} = Version.parse("2.2/4")
      iex> v1
      #Version<2.2>
      iex> v2
      #Version<2.3>
      iex> v3
      #Version<2.4>

      iex> {:ok, version} = Version.parse("1.2")
      iex> {:ok, version} = Version.parse(version)
      iex> version
      #Version<1.2>
  """
  @spec parse(String.t() | t()) :: {:ok, t()} | :error
  def parse(string) when is_binary(string) do
    case String.split(string, @range) do
      [version] ->
        create(version)

      [version, last] ->
        with {:ok, first} <- create(version) do
          range(first, last)
        end
    end
  end

  def parse(%__MODULE__{} = version), do: {:ok, version}

  @doc """
  Parses a version string into a `GitHubActions.Version` struct.

  If `string` is an invalid version, a GitHubActions.InvalidVersionError is raised.

  ## Examples

      iex> Version.parse!("1")
      #Version<1>

      iex> Version.parse!("1.2")
      #Version<1.2>

      iex> Version.parse!("1.2.3")
      #Version<1.2.3>

      iex> Version.parse!("invalid")
      ** (GitHubActions.InvalidVersionError) invalid version: "invalid"
  """
  @spec parse!(String.t() | t()) :: t()
  def parse!(string) when is_binary(string) do
    case parse(string) do
      {:ok, version} -> version
      :error -> raise GitHubActions.InvalidVersionError, string
    end
  end

  def parse!(%__MODULE__{} = version), do: version

  @doc """
  Checks if the given version matches the specification.

  Returns `true` if `version` satisfies `requirement`, `false` otherwise.
  Raises a `Version.InvalidRequirementError` exception if `requirement` is not
  parsable, or a `GitHubActions.InvalidVersionError` exception if `version` is
  not parsable.

  ## Examples

      iex> Version.match?("2.0", "> 1.0.0")
      true

      iex> Version.match?("2.0", "== 1.0.0")
      false

      iex> Version.match?("2.2.6", "~> 2.2.2")
      true

      iex> Version.match?("2.3", "~> 2.2")
      true

      iex> Version.match?("2", "~> 2.1.2")
      false

      iex> Version.match?("a.b.c", "~> 2.1.2")
      ** (GitHubActions.InvalidVersionError) invalid version: "a.b.c"

      iex> Version.match?("2", "~~~> 2.1.2")
      ** (Version.InvalidRequirementError) invalid requirement: "~~~> 2.1.2"
  """
  @spec match?(version(), requirement()) :: boolean
  def match?(version, requirement) when is_binary(requirement) do
    match?(version, Version.parse_requirement!(requirement))
  end

  def match?(version, requirement) do
    Requirement.match?(requirement, to_matchable(version))
  end

  @spec compare(version(), version(), :minor | :patch) :: :gt | :lt | :eq
  def compare(a, b, precision \\ :patch) do
    do_compare(to_matchable(a), to_matchable(b), precision)
  end

  defp do_compare(
         {major1, minor1, patch1, _pre1, _build1},
         {major2, minor2, patch2, _pre2, _build2},
         precision
       ) do
    cond do
      major1 > major2 -> :gt
      major1 < major2 -> :lt
      minor1 > minor2 and precision in [:minor, :patch] -> :gt
      minor1 < minor2 and precision in [:minor, :patch] -> :lt
      patch1 > patch2 and precision == :patch -> :gt
      patch1 < patch2 and precision == :patch -> :lt
      true -> :eq
    end
  end

  defp create(string) do
    string
    |> String.split(@separator)
    |> Enum.map(&to_integer/1)
    |> create(@fields)
  end

  defp create(values, keys, data \\ [])

  defp create([], _keys, data) do
    {:ok, struct!(__MODULE__, Enum.reverse(data))}
  end

  defp create([{:ok, value} | values], [key | keys], data) when is_integer(value) do
    create(values, keys, [{key, value} | data])
  end

  defp create(_values, _keys, _data), do: :error

  defp to_integer(str) do
    case Integer.parse(str) do
      {int, ""} -> {:ok, int}
      _error -> :error
    end
  end

  defp to_matchable(str) when is_binary(str) do
    str |> parse!() |> to_matchable()
  end

  defp to_matchable(%__MODULE__{major: major, minor: minor, patch: patch}) do
    # The last two values are in the tuple to make it compatible to the
    # Requirement matchable_pattern.
    {major || 0, minor || 0, patch || 0, [], false}
  end

  defp range(%__MODULE__{major: major, minor: minor, patch: patch}, last) do
    case Integer.parse(last) do
      {int, ""} ->
        {:ok, range({major, minor, patch}, int, [])}

      _error ->
        :error
    end
  end

  defp range({major, nil, nil}, range, versions) when major <= range do
    range({major + 1, nil, nil}, range, [
      struct!(__MODULE__, major: major, minor: nil, patch: nil) | versions
    ])
  end

  defp range({major, minor, nil}, range, versions) when minor <= range do
    range({major, minor + 1, nil}, range, [
      struct!(__MODULE__, major: major, minor: minor, patch: nil) | versions
    ])
  end

  defp range({major, minor, patch}, range, versions) when patch <= range do
    range({major, minor, patch + 1}, range, [
      struct(__MODULE__, major: major, minor: minor, patch: patch) | versions
    ])
  end

  defp range(_version, _range, versions), do: Enum.reverse(versions)

  @doc """
  Returns the requiement for the given `version` and `operator`.

  ## Examples

      iex> Version.to_requirement("1", "==")
      "== 1.0.0"
      iex> Version.to_requirement("1.1", ">=")
      ">= 1.1.0"
      iex> Version.to_requirement("1.1", "~>")
      "~> 1.1"
      iex> Version.to_requirement("1.1.1", "~>")
      "~> 1.1.1"
  """
  @spec to_requirement(version(), String.t()) :: String.t()
  def to_requirement(version, operator)
      when is_binary(version) and operator in @requirement_operators do
    version |> parse!() |> to_requirement(operator)
  end

  def to_requirement(%__MODULE__{major: major, minor: minor, patch: patch}, operator)
      when operator in @requirement_operators do
    case operator do
      "~>" ->
        "#{operator} #{major}#{next(minor)}#{next(patch)}"

      _else ->
        "#{operator} #{major}.#{minor || 0}.#{patch || 0}"
    end
  end

  @doc false
  def next(nil), do: ""
  def next(num) when is_integer(num), do: ".#{num}"
end

defimpl String.Chars, for: GitHubActions.Version do
  alias GitHubActions.Version

  def to_string(version) do
    "#{version.major}#{Version.next(version.minor)}#{Version.next(version.patch)}"
  end
end

defimpl Inspect, for: GitHubActions.Version do
  def inspect(self, _opts) do
    "#Version<#{to_string(self)}>"
  end
end

defmodule GitHubActions.InvalidVersionError do
  defexception [:version]

  @impl true
  def exception(version) when is_binary(version) do
    %__MODULE__{version: version}
  end

  @impl true
  def message(%{version: version}) do
    "invalid version: #{inspect(version)}"
  end
end
