defmodule GitHubActions.Versions do
  @moduledoc """
  Functions to select and filter lists and tables of versions.

  The list of versions can have the following two forms.
  - A simple list:
    ```elixir
    ["1", "2.0", "2.1", "3", "3.1", "3.1.1"]
    ```
  - A table as list of keyword lists with compatible versions:
    ```elixir
    [
      [a: ["1.0.0"], b: ["1.0", "1.1", "1.2"]],
      [a: ["2.0.0"], b: ["1.2", "2.0"]]
    ]
    ```
  """

  alias GitHubActions.Config
  alias GitHubActions.Version
  alias GitHubActions.Versions.Impl

  @type versions_list :: [Version.version()]
  @type versions_table :: [keyword(Version.version())]
  @type versions :: versions_list() | versions_table()
  @type key :: atom()

  @doc """
  Returns the latest version from the configured versions list.

  ## Examples

      iex> Config.config(:versions, ["1.0.0/2", "1.1.0/3"])
      iex> Versions.latest()
      #Version<1.1.3>
  """
  @spec latest :: Version.t()
  def latest, do: latest(from_config())

  @doc """
  Returns the latest version from the configured `versions` table by the given
  `key` or from the given `versions` list.

  ## Examples

      iex> Versions.latest(["1.0.0/2", "1.1.0/3"])
      #Version<1.1.3>

      iex> Config.config(:versions, [
      ...>   [a: ["1.0.0/2", "1.1.0/3"], b: ["2.0/5"]],
      ...>   [a: ["1.2.0/1", "1.3.0/4"], b: ["3.0/5"]]
      ...> ])
      iex> Versions.latest(:a)
      #Version<1.3.4>

      iex> Versions.latest(["foo"])
      ** (GitHubActions.InvalidVersionError) invalid version: "foo"

      iex> Versions.latest([a: "1"])
      ** (ArgumentError) latest/1 expected a list or table of versions or a key, got: [a: "1"]

      iex> Versions.latest(:elixir)
      #Version<1.13.0>

      iex> Versions.latest(:otp)
      #Version<24.1>
  """
  @spec latest(versions() | key()) :: Version.t()
  def latest(versions_or_key) when is_list(versions_or_key) do
    case Impl.type(versions_or_key) do
      {:list, versions} ->
        Impl.latest(versions)

      :error ->
        raise ArgumentError,
          message: """
          latest/1 expected a list or table of versions or a key, \
          got: #{inspect(versions_or_key)}\
          """
    end
  end

  def latest(key) when is_atom(key), do: latest(from_config(), key)

  @doc """
  Returns the latest version from a `versions` table by the given `key`.

  ## Examples

      iex> Versions.latest([
      ...>   [a: ["1.0.0/2"], b: ["1.0.0/3"]],
      ...>   [a: ["1.1.0/3"], b: ["1.1.0/4"]]
      ...> ], :a)
      #Version<1.1.3>

      iex> Versions.latest([a: "1"], :a)
      ** (ArgumentError) latest/1 expected a table of versions,  got: [a: "1"]
  """
  @spec latest(versions_table(), key()) :: Version.t()
  def latest(versions, key) when is_list(versions) and is_atom(key) do
    case Impl.type(versions) do
      {:table, versions} ->
        Impl.latest(versions, key)

      :error ->
        raise ArgumentError,
          message: "latest/1 expected a table of versions,  got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns the latest minor versions from the configured versions list.

  ## Examples

      iex> Config.config(:versions, ["1.0.0/2", "1.1.0/4", "2.0.0/3"])
      iex> Versions.latest_minor() |> Enum.map(&to_string/1)
      ["1.0.2", "1.1.4", "2.0.3"]
  """
  @spec latest_minor :: [Version.t()]
  def latest_minor, do: latest_minor(from_config())

  @doc """
  Returns the latest minor versions from the configured `versions` table by the
  given `key` or from the given `versions` list.

  ## Examples

      iex> minor_versions = Versions.latest_minor(["1.0.0/2", "1.1.0/3"])
      iex> Enum.map(minor_versions, &to_string/1)
      ["1.0.2", "1.1.3"]

      iex> Config.config(:versions, [
      ...>   [a: ["1.0.0/2", "1.1.0/3"], b: ["2.0/5"]],
      ...>   [a: ["1.2.0/1", "1.3.0/4"], b: ["3.0/5"]]
      ...> ])
      iex> minor_versions = Versions.latest_minor(:a)
      iex> Enum.map(minor_versions, &to_string/1)
      ["1.0.2", "1.1.3", "1.2.1", "1.3.4"]

      iex> Versions.latest_minor(["foo"])
      ** (GitHubActions.InvalidVersionError) invalid version: "foo"

      iex> Versions.latest_minor([a: "1"])
      ** (ArgumentError) latest_minor/1 expected a list or table of versions or a key, got: [a: "1"]

      iex> minor_versions = Versions.latest_minor(:elixir)
      iex> Enum.map(minor_versions, &to_string/1)
      ["1.0.5", "1.1.1", "1.2.6", "1.3.4", "1.4.5", "1.5.3", "1.6.6", "1.7.4",
       "1.8.2", "1.9.4", "1.10.4", "1.11.4", "1.12.3", "1.13.0"]

      iex> minor_versions = Versions.latest_minor(:otp)
      iex> Enum.map(minor_versions, &to_string/1)
      ["17.0", "17.1", "17.2", "17.3", "17.4", "17.5", "18.0", "18.1", "18.2",
       "18.3", "19.0", "19.1", "19.2", "19.3", "20.0", "20.1", "20.2", "20.3",
       "21.0", "21.1", "21.2", "21.3", "22.0", "22.1", "22.2", "22.3", "23.0",
       "23.1", "23.2", "23.3", "24.0", "24.1"]
  """
  @spec latest_minor(versions_list() | key()) :: [Version.t()]
  def latest_minor(versions_or_key) when is_list(versions_or_key) do
    case Impl.type(versions_or_key) do
      {_type, versions} ->
        Impl.latest_minor(versions)

      _error ->
        raise ArgumentError,
          message: """
          latest_minor/1 expected a list or table of versions or a key, \
          got: #{inspect(versions_or_key)}\
          """
    end
  end

  def latest_minor(key) when is_atom(key), do: latest_minor(from_config(), key)

  @doc """
  Returns the latest minor versions from a `versions` table by the given `key`.

  ## Examples

      iex> minor_versions = Versions.latest_minor([
      ...>   [a: ["1.0.0/2"], b: ["1.0.0/3"]],
      ...>   [a: ["1.1.0/3"], b: ["1.1.0/4"]]
      ...> ], :a)
      iex> Enum.map(minor_versions, &to_string/1)
      ["1.0.2", "1.1.3"]

      iex> Versions.latest_minor([a: "1"], :a)
      ** (ArgumentError) latest_minor/1 expected a table of versions,  got: [a: "1"]
  """
  @spec latest_minor(versions_table(), key()) :: [Version.t()]
  def latest_minor(versions, key) when is_list(versions) and is_atom(key) do
    case Impl.type(versions) do
      {:table, versions} ->
        Impl.latest_minor(versions, key)

      :error ->
        raise ArgumentError,
          message: "latest_minor/1 expected a table of versions,  got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns the latest major versions from the configured versions list.

  ## Examples

      iex> Config.config(:versions, ["1.0.0/2", "1.1.0/4", "2.0.0/3"])
      iex> Versions.latest_major() |> Enum.map(&to_string/1)
      ["1.1.4", "2.0.3"]
  """
  @spec latest_major :: [Version.t()]
  def latest_major, do: latest_major(from_config())

  @doc """
  Returns the latest major versions from the configured `versions` table by the
  given `key` or from the given `versions` list.

  ## Examples

      iex> major_versions = Versions.latest_major(["1.0.0/2", "1.1.0/3", "2.0.0/2"])
      iex> Enum.map(major_versions, &to_string/1)
      ["1.1.3", "2.0.2"]

      iex> Config.config(:versions, [
      ...>   [a: ["1.0.0/2", "1.1.0/3"], b: ["2.0/5"]],
      ...>   [a: ["2.2.0/1", "2.3.0/4"], b: ["3.0/5"]]
      ...> ])
      iex> major_versions = Versions.latest_major(:a)
      iex> Enum.map(major_versions, &to_string/1)
      ["1.1.3", "2.3.4"]

      iex> Versions.latest_major(["foo"])
      ** (GitHubActions.InvalidVersionError) invalid version: "foo"

      iex> Versions.latest_major([a: "1"])
      ** (ArgumentError) latest_major/1 expected a list or table of versions or a key, got: [a: "1"]

      iex> major_versions = Versions.latest_major(:elixir)
      iex> Enum.map(major_versions, &to_string/1)
      ["1.13.0"]

      iex> major_versions = Versions.latest_major(:otp)
      iex> Enum.map(major_versions, &to_string/1)
      ["17.5", "18.3", "19.3", "20.3", "21.3", "22.3", "23.3", "24.1"]
  """
  @spec latest_major(versions_list() | key()) :: [Version.t()]
  def latest_major(versions_or_key) when is_list(versions_or_key) do
    case Impl.type(versions_or_key) do
      {_type, versions} ->
        Impl.latest_major(versions)

      :error ->
        raise ArgumentError,
          message: """
          latest_major/1 expected a list or table of versions or a key, \
          got: #{inspect(versions_or_key)}\
          """
    end
  end

  def latest_major(key) when is_atom(key), do: latest_major(from_config(), key)

  @doc """
  Returns the latest major versions from a `versions` table by the given `key`.

  ## Examples

      iex> major_versions = Versions.latest_major([
      ...>   [a: ["1.0.0/2"], b: ["1.0.0/3"]],
      ...>   [a: ["2.0.0/3"], b: ["2.0.0/4"]]
      ...> ], :a)
      iex> Enum.map(major_versions, &to_string/1)
      ["1.0.2", "2.0.3"]

      iex> Versions.latest_major([a: "1"], :a)
      ** (ArgumentError) latest_major/1 expected a table of versions,  got: [a: "1"]
  """
  @spec latest_major(versions_table(), key()) :: [Version.t()]
  def latest_major(versions, key) when is_list(versions) and is_atom(key) do
    case Impl.type(versions) do
      {:table, versions} ->
        Impl.latest_major(versions, key)

      _error ->
        raise ArgumentError,
          message: "latest_major/1 expected a table of versions,  got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns all versions for `key` from a list of compatible versions.

  This function raises a `GitHubActions.InvalidVersionError` for an invalid
  version.

  ## Examples

      iex> versions = [
      ...>   [a: ["1.0.0"], b: ["1.0", "1.1", "1.2"]],
      ...>   [a: ["2.0.0"], b: ["1.2", "2.0"]]
      ...> ]
      iex> versions = Versions.get(versions, :b)
      iex> hd versions
      #Version<1.0>
      iex> Enum.map(versions, &to_string/1)
      ["1.0", "1.1", "1.2", "2.0"]

      iex> Versions.get([a: "1"], :a)
      ** (ArgumentError) get/2 expected a table of versions, got: [a: "1"]
  """
  @spec get(versions_table(), key()) :: [Version.t()]
  def get(versions \\ from_config(), key) when is_list(versions) do
    case Impl.type(versions) do
      {:table, versions} ->
        Impl.get(versions, key)

      _error ->
        raise ArgumentError,
          message: "get/2 expected a table of versions, got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns the versions from the config.
  """
  @spec from_config :: versions()
  def from_config, do: Config.get(:versions)

  @doc """
  Sorts the given `versions`.

  ## Examples

      iex> versions = ["1.1", "11.1", "1.0", "2.1", "2.0.1", "2.0.0"]
      iex> versions = Versions.sort(versions)
      iex> Enum.map(versions, &to_string/1)
      ["1.0", "1.1", "2.0.0", "2.0.1", "2.1", "11.1"]

      iex> Versions.sort([a: ["1", "2"]])
      ** (ArgumentError) sort/2 expected a list or table of versions, got: [a: ["1", "2"]]
  """
  @spec sort([Version.version()]) :: [Version.version()]
  def sort(versions) do
    case Impl.type(versions) do
      {:list, versions} ->
        Impl.sort_list(versions)

      {:table, versions} ->
        Impl.sort_table(versions)

      :error ->
        raise ArgumentError,
          message: "sort/2 expected a list or table of versions, got: #{inspect(versions)}"
    end
  end

  @doc """
  Removes all duplicated versions.

  ## Examples

      iex> versions = Versions.expand(["1.0.0/4", "1.0.2/5"])
      iex> versions |> Versions.uniq() |> Enum.map(&to_string/1)
      ["1.0.0", "1.0.1", "1.0.2", "1.0.3", "1.0.4", "1.0.5"]

      iex> Versions.uniq([:a])
      ** (ArgumentError) uniq/1 expected a list or table of versions, got: [:a]
  """
  @spec uniq(versions()) :: versions()
  def uniq(versions) do
    case Impl.type(versions) do
      {_type, versions} ->
        versions

      :error ->
        raise ArgumentError,
          message: "uniq/1 expected a list or table of versions, got: #{inspect(versions)}"
    end
  end

  @doc """
  Filters the list of `versions` by the given `requirement`.

  ## Examples

      iex> versions = ["1", "1.1.0/5", "1.2.0/1", "1.3", "2.0/1"]
      iex> Versions.filter(versions, "~> 1.2")
      [
        %Version{major: 1, minor: 2, patch: 0},
        %Version{major: 1, minor: 2, patch: 1},
        %Version{major: 1, minor: 3}
      ]
      iex> Versions.filter(versions, ">= 1.3.0")
      [
        %Version{major: 1, minor: 3},
        %Version{major: 2, minor: 0},
        %Version{major: 2, minor: 1}
      ]

      iex> Versions.filter([:b, :a], "> 1.0.0")
      ** (ArgumentError) filter/2 expected a list of versions, got: [:b, :a]

      iex> Versions.filter(["1", "2", "3"], "> 1")
      ** (Version.InvalidRequirementError) invalid requirement: "> 1"
  """
  @spec filter(versions_list(), String.t()) :: [Version.t()]
  def filter(versions, requirement) when is_binary(requirement) do
    case Impl.type(versions) do
      {:list, versions} ->
        Impl.filter(versions, requirement)

      _error ->
        raise ArgumentError,
          message: "filter/2 expected a list of versions, got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns true if `versions` contains the given `version`.

  ## Examples

      iex> versions = ["1.0.0", "1.1.0", "1.1.1"]
      iex> Versions.member?(versions, "1.1")
      true
      iex> Versions.member?(versions, "1.0.1")
      false

      iex> Versions.member?([a: "1"], "1.0.0")
      ** (ArgumentError) member?/2 expected a list of versions, got: [a: "1"]
  """
  @spec member?(versions_list(), Version.version()) :: boolean
  def member?(versions, version) do
    case Impl.type(versions) do
      {:list, versions} ->
        Impl.member?(versions, version)

      _error ->
        raise ArgumentError,
          message: "member?/2 expected a list of versions, got: #{inspect(versions)}"
    end
  end

  @doc """
  Returns true if `versions1` has an intersection with `versions2`.

  ## Examples

      iex> Versions.intersection?(["1.0.0/5"], ["1.0.4/7"])
      true

      iex> Versions.intersection?(["1.0.0/5"], ["2.0.0/7"])
      false

      iex> Versions.intersection?(["1.0.0/5"], [:a])
      ** (ArgumentError) intersection?/2 expected two list of versions, got: ["1.0.0/5"], [:a]
  """
  @spec intersection?(versions_list(), versions_list()) :: boolean()
  def intersection?(versions1, versions2) do
    with {:list, versions1} <- Impl.type(versions1),
         {:list, versions2} <- Impl.type(versions2) do
      Impl.intersection?(versions1, versions2)
    else
      :error ->
        raise ArgumentError,
          message: """
          intersection?/2 expected two list of versions, \
          got: #{inspect(versions1)}, #{inspect(versions2)}\
          """
    end
  end

  @doc """
  Returns the versions of `key` that are compatible with `to`.

  ## Examples

      iex> otp = Versions.compatible(:otp, elixir: "1.6.6")
      iex> Enum.map(otp, &to_string/1)
      ["19.0", "19.1", "19.2", "19.3", "20.0", "20.1", "20.2", "20.3", "21.0",
       "21.1", "21.2", "21.3"]

      iex> elixir = Versions.compatible(:elixir, otp: "20.3")
      iex> Enum.map(elixir, &to_string/1)
      ["1.4.5", "1.5.0", "1.5.1", "1.5.2", "1.5.3", "1.6.0", "1.6.1", "1.6.2",
       "1.6.3", "1.6.4", "1.6.5", "1.6.6", "1.7.0", "1.7.1", "1.7.2", "1.7.3",
       "1.7.4", "1.8.0", "1.8.1", "1.8.2", "1.9.0", "1.9.1", "1.9.2", "1.9.3",
       "1.9.4"]

      iex> :otp |> Versions.compatible(elixir: "1.10.0") |> Enum.count()
      8

      iex> :otp |> Versions.compatible(elixir: "1.10.0/4") |> Enum.count()
      12

      iex> :otp |> Versions.compatible(elixir: ["1.10.0/4", "1.11.0/4"]) |> Enum.count()
      14

      iex> Versions.compatible([], :otp, elixir: "1.6.6")
      ** (ArgumentError) compatible/3 expected a table of versions as first argument, got: []
  """
  @spec compatible(versions(), key(), [{key(), Version.version()}]) :: [Version.t()]
  def compatible(versions \\ from_config(), key, [{to_key, to_versions}])
      when is_atom(key) and is_atom(to_key) do
    versions =
      case Impl.type(versions) do
        {:table, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            compatible/3 expected a table of versions as first argument, \
            got: #{inspect(versions)}\
            """
      end

    to_versions =
      case to_versions |> List.wrap() |> Impl.type() do
        {:list, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            compatible/3 expected a list of versions for #{inspect(to_key)}, \
            got: #{inspect(to_versions)}\
            """
      end

    Impl.compatible(versions, key, {to_key, to_versions})
  end

  @doc """
  Returns `true` if the given `version1` is compatible to `version2`.

  ## Examples

      iex> Versions.compatible?(elixir: "1.12.3", otp: "24.0")
      true

      iex> Versions.compatible?(elixir: "1.6.0", otp: "24.0")
      false

      iex> versions = [
      ...>   [a: ["1.0.0"], b: ["1.0", "1.1", "1.2"]],
      ...>   [a: ["2.0.0"], b: ["1.2", "2.0"]]
      ...> ]
      iex> Versions.compatible?(versions, a: "1", b: "1.2")
      true
      iex> Versions.compatible?(versions, a: "2", b: "1.2")
      true
      iex> Versions.compatible?(versions, a: "2", b: "1")
      false

      iex> Versions.compatible?([], a: "1", b: "2")
      ** (ArgumentError) compatible?/2 expected a table of versions as first argument, got: []
  """
  @spec compatible?(
          versions(),
          [{key(), Version.version()}]
        ) :: boolean()
  def compatible?(versions \\ from_config(), [{key1, version1}, {key2, version2}])
      when is_atom(key1) and is_atom(key2) do
    versions =
      case Impl.type(versions) do
        {:table, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            compatible?/2 expected a table of versions as first argument, \
            got: #{inspect(versions)}\
            """
      end

    version1 = Version.parse!(version1)
    version2 = Version.parse!(version2)

    Impl.compatible?(versions, {key1, version1}, {key2, version2})
  end

  @doc """
  Returns the incompatible versions between `versions1` and `versions2`.

  ## Examples

      iex> versions = Versions.incompatible(
      ...>   elixir: ["1.9.4", "1.10.4", "1.11.4", "1.12.3"],
      ...>   otp: ["21.3", "22.3", "23.3", "24.0"]
      ...> )
      iex> for [{k1, v1}, {k2, v2}] <- versions do
      ...>   [{k1, to_string(v1)}, {k2, to_string(v2)}]
      ...> end
      [
        [elixir: "1.9.4", otp: "23.3"],
        [elixir: "1.9.4", otp: "24.0"],
        [elixir: "1.10.4", otp: "24.0"],
        [elixir: "1.12.3", otp: "21.3"]
      ]
  """
  def incompatible(versions \\ from_config(), [{key1, versions1}, {key2, versions2}])
      when is_atom(key1) and is_atom(key2) do
    versions =
      case Impl.type(versions) do
        {:table, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            incompatible/2 expected a table of versions as first argument, \
            got: #{inspect(versions)}\
            """
      end

    versions1 =
      case Impl.type(versions1) do
        {:list, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            incompatible/2 expected a list of versions for #{inspect(key1)}, \
            got: #{inspect(versions1)}\
            """
      end

    versions2 =
      case Impl.type(versions2) do
        {:list, versions} ->
          versions

        _error ->
          raise ArgumentError,
            message: """
            incompatible/2 expected a list of versions for #{inspect(key2)}, \
            got: #{inspect(versions2)}\
            """
      end

    Impl.incompatible(versions, {key1, versions1}, {key2, versions2})
  end

  @doc """
  Returns the versions matrix for the given requirements.

  ## Examples

      iex> matrix = Versions.matrix(elixir: ">= 1.9.0", otp: ">= 22.0.0")
      iex> Enum.map(matrix[:elixir], &to_string/1)
      ["1.9.4", "1.10.4", "1.11.4", "1.12.3", "1.13.0"]
      iex> Enum.map(matrix[:otp], &to_string/1)
      ["22.3", "23.3", "24.1"]
      iex> for [{k1, v1}, {k2, v2}] <- matrix[:exclude] do
      ...>   [{k1, to_string(v1)}, {k2, to_string(v2)}]
      ...> end
      [
        [elixir: "1.9.4", otp: "23.3"],
        [elixir: "1.9.4", otp: "24.1"],
        [elixir: "1.10.4", otp: "24.1"]
      ]

      iex> Versions.matrix([], elixir: ">= 1.9.0", otp: ">= 22.0.0")
      ** (ArgumentError) matrix/1 expected a table of versions as first argument, got: []

  """
  def matrix(versions \\ from_config(), opts) do
    case Impl.type(versions) do
      {:table, versions} ->
        Impl.matrix(versions, opts)

      _error ->
        raise ArgumentError,
          message: """
          matrix/1 expected a table of versions as first argument, \
          got: #{inspect(versions)}\
          """
    end
  end

  @doc """
  Expands the given `versions`.

  ## Examples

      iex> versions = Versions.expand(["1.0/2"])
      iex> Enum.map(versions, &to_string/1)
      ["1.0", "1.1", "1.2"]

      iex> versions = Versions.expand([
      ...>  [a: ["1.0/2"], b: ["1.0.0/2"]],
      ...>  [a: ["1.1.0/1"], b: ["2.0.0/2"]]
      ...> ])
      iex> versions |> Enum.at(1) |> Keyword.get(:a) |> Enum.map(&to_string/1)
      ["1.1.0", "1.1.1"]
      iex> versions |> Enum.at(1) |> Keyword.get(:b) |> Enum.map(&to_string/1)
      ["2.0.0", "2.0.1", "2.0.2"]

      iex> Versions.expand([:a])
      ** (ArgumentError) expand/1 expected a list of versions, or tabel of versions got: [:a]
  """
  @spec expand(versions()) :: versions()
  def expand(versions) do
    case Impl.type(versions) do
      {_type, versions} ->
        versions

      :error ->
        raise ArgumentError,
          message: """
          expand/1 expected a list of versions, or tabel of versions \
          got: #{inspect(versions)}\
          """
    end
  end

  defmodule Impl do
    @moduledoc false

    def type(versions) when is_list(versions) do
      # Impl.expand(versions)
      case {table?(versions), list?(versions)} do
        {true, false} ->
          {:table, expand(versions) |> uniq() |> sort_table()}

        {false, true} ->
          {:list, expand(versions) |> Enum.uniq() |> sort_list()}

        _else ->
          :error
      end
    end

    def type(_versions), do: :error

    defp table?(versions) do
      Enum.all?(versions, &Keyword.keyword?/1) &&
        versions |> Enum.map(&Keyword.keys/1) |> Enum.uniq() |> Enum.count() == 1
    end

    defp list?(versions) do
      Enum.all?(versions, fn version ->
        cond do
          is_binary(version) -> true
          is_struct(version, Version) -> true
          true -> false
        end
      end)
    end

    def sort_list(versions) do
      Enum.sort(versions, fn a, b -> Version.compare(a, b) == :lt end)
    end

    def sort_table(versions) do
      versions
      |> Enum.map(&sort_table_row/1)
      |> sort_table_rows()
    end

    defp sort_table_row(row) do
      Enum.map(row, fn {key, list} -> {key, sort_list(list)} end)
    end

    defp sort_table_rows([]), do: []

    defp sort_table_rows([[]]), do: [[]]

    defp sort_table_rows([[{key, _version} | _versions] | _rows] = rows) do
      Enum.sort(rows, fn a, b ->
        case {Enum.at(a[key], 0), Enum.at(b[key], 0)} do
          {nil, nil} -> false
          {_, nil} -> false
          {nil, _} -> true
          {x, y} -> Version.compare(x, y) == :lt
        end
      end)
    end

    defp uniq(versions) do
      Enum.map(versions, fn row -> Enum.uniq(row) end)
    end

    defp expand(versions) do
      Enum.flat_map(versions, fn version -> do_expand(version) end)
    end

    defp do_expand(version) when is_binary(version) or is_struct(version) do
      version |> Version.parse!() |> List.wrap()
    end

    defp do_expand(versions) when is_list(versions) do
      [Enum.map(versions, fn {key, versions} -> {key, expand(versions)} end)]
    end

    def latest(versions), do: List.last(versions)

    def latest(versions, key), do: versions |> get(key) |> List.last()

    def latest_minor(versions), do: do_latest(versions, :minor)

    def latest_minor(versions, key), do: versions |> get(key) |> do_latest(:minor)

    def latest_major(versions), do: do_latest(versions, :major)

    def latest_major(versions, key), do: versions |> get(key) |> do_latest(:major)

    defp do_latest(versions, precision) do
      Enum.reduce(versions, [], fn
        version, [] ->
          [Version.parse!(version)]

        version, [current | rest] = acc ->
          case Version.compare(version, current, precision) do
            :eq -> [Version.parse!(version) | rest]
            :gt -> [Version.parse!(version) | acc]
          end
      end)
      |> Enum.reverse()
    end

    def member?(versions, version) do
      Enum.any?(versions, fn item -> Version.compare(item, version) == :eq end)
    end

    def intersection?(versions1, versions2) do
      Enum.any?(versions1, fn version -> member?(versions2, version) end)
    end

    def filter(versions, requirement) do
      Enum.filter(versions, fn version -> Version.match?(version, requirement) end)
    end

    def compatible(versions, key, {to_key, to_versions}) do
      Enum.flat_map(versions, fn row ->
        case row |> Keyword.get(to_key, []) |> intersection?(to_versions) do
          true -> Keyword.get(row, key, [])
          false -> []
        end
      end)
    end

    def compatible?(versions, {key1, version1}, {key2, version2}) do
      versions
      |> compatible(key2, {key1, List.wrap(version1)})
      |> member?(version2)
    end

    def incompatible(versions, {key1, versions1}, {key2, versions2}) do
      for version1 <- versions1,
          version2 <- versions2,
          compatible?(versions, {key1, version1}, {key2, version2}) == false do
        [{key1, version1}, {key2, version2}]
      end
    end

    def get(versions, key) do
      versions
      |> Enum.flat_map(fn lists -> Keyword.get(lists, key, []) end)
      |> Enum.uniq()
      |> sort_list()
    end

    def matrix(versions, opts) do
      elixir =
        versions
        |> get(:elixir)
        |> filter(Keyword.fetch!(opts, :elixir))
        |> latest_minor()

      otp =
        versions
        |> compatible(:otp, {:elixir, elixir})
        |> filter(Keyword.fetch!(opts, :otp))
        |> latest_major()

      exclude = incompatible(versions, {:elixir, elixir}, {:otp, otp})

      [
        elixir: elixir,
        otp: otp,
        exclude: exclude
      ]
    end
  end
end
