defmodule GitHubActions do
  @moduledoc """
  A little tool to write GitHub actions in Elixir.
  """

  import Mix.Generator

  alias GitHubActions.Config
  alias GitHubActions.Workflow
  alias GitHubActions.Yaml

  @version Mix.Project.config()[:version]

  @workflow "default.exs"
  @config "config.exs"
  @dir ".gha"

  @doc """
  Creates a GitHub actions workflow file.
  """
  def run(opts) do
    read_config(opts)

    opts
    |> workflow()
    |> Yaml.encode()
    |> write(opts)
  end

  @doc false
  def copy(gen_global: true) do
    create_directory(global())
    copy_file(priv(@config), global(@config))
    copy_file(priv(@workflow), global(@workflow))
  end

  def copy(gen_local: true) do
    create_directory(local())
    copy_file(priv(@config), local(@config))
    copy_file(priv(@workflow), local(@workflow))
  end

  def copy(_opts) do
    raise GitHubActions.Error, "option --gen-local or --gen-global is required"
  end

  defp read_config(opts) do
    # read default config first
    Config.read(priv(@config))
    if File.exists?(global(@config)), do: Config.read(global(@config))
    if File.exists?(local(@config)), do: Config.read(local(@config))

    case Keyword.fetch!(opts, :config) do
      :default -> :ok
      config -> Config.read(config)
    end
  end

  defp workflow do
    case default_input() do
      {:ok, path} ->
        workflow(path)

      {:error, script} ->
        raise GitHubActions.Error, "no workflow script found, sought: #{inspect(script)}"
    end
  end

  defp workflow(opts) when is_list(opts) do
    opts |> Keyword.fetch!(:workflow) |> workflow()
  end

  defp workflow(:default), do: workflow()

  defp workflow(path) do
    case Workflow.eval(path) do
      {:ok, workflow} -> workflow
      :error -> raise GitHubActions.Error, "invalid workflow script, script: #{inspect(path)}"
    end
  end

  defp default_input do
    workflow = Config.get([:input, :default], @workflow)

    Enum.find_value(
      [
        local(workflow),
        global(workflow),
        priv(workflow)
      ],
      {:error, workflow},
      fn path ->
        with true <- File.exists?(path) do
          {:ok, path}
        end
      end
    )
  end

  defp write(yaml, opts) do
    path = output_path(opts)

    comment =
      case Config.get([:output, :comment], true) do
        true -> "# Created with GitHubActions version #{@version}\n"
        false -> ""
      end

    create_file(
      path,
      comment <> yaml,
      force: true
    )
  end

  defp output_path(opts) do
    with :default <- Keyword.fetch!(opts, :output) do
      Path.join(
        Config.fetch!([:output, :path]),
        Config.fetch!([:output, :file])
      )
    end
  end

  defp local, do: @dir

  defp global, do: Path.join(System.user_home!(), @dir)

  defp local(file), do: Path.join(@dir, file)

  defp global(file), do: Path.join([System.user_home!(), @dir, file])

  defp priv(file), do: Path.join(:code.priv_dir(:git_hub_actions), file)

  defmodule Error do
    defexception [:message]
  end
end
