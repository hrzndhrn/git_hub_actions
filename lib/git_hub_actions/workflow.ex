defmodule GitHubActions.Workflow do
  @moduledoc """
  The `GitHubActions.Workflow` is used to create a GitHub actions workflow.

  ```elixir
  defmodule Minimal do
    use GitHubActions.Workflow

    def workflow do
      [
        name: "CI"
      ]
    end
  end
  ```

  The workflow module must define the `workflow/0` function. This function
  returns a nested data structure that will be translated in a yml-file.

  The line `use GitHubActions.Workflow` imports `GitHubActions.Workflow`,
  `GitHubActions.Mix` and `GitHubActions.Sigils` and adds the aliases
  `GitHubActions.Config`, `GitHubActions.Project` and `GitHubActions.Versions`.

  List entries with the value `:skip` are not taken over.

  Key-value pairs with a value of `:skip` are also not part of the resulting
  data structure.

  With :skip, you can handle optional parts in a workflow script.

  ~S```elixir
  defmodule Simple do
    use GitHubActions.Workflow

    def workflow do
      [
        name: "CI",
        jobs: [
          linux: linux(),
          os2: os2()
        ]
      ]
    end

    defp linux do
      job(:linux,
        name: "Test on \#{Config.fetch!([:linux, :name])}",
        runs_on: Config.fetch!([:linux, :runs_on])
      )
    end

    defp os2 do
      job(:linux,
        name: "Test on \#{Config.fetch!([:os2, :name])}",
        runs_on: Config.fetch!([:os2, :runs_on])
      )
    end

    defp job(os, config) do
      case :jobs |> Config.get([]) |> Enum.member?(os) do
        true -> config
        false -> :skip
      end
    end
  end
  ```

  It is also possible to add steps when a dependency is available in the current
  project.

  ~S```elixir
  defmodule Simple do
    use GitHubActions.Workflow

    def workflow do
      [
        name: "CI",
        jobs: [linux: linux()]
      ]
    end

    defp linux do
      name: "Test on \#{Config.fetch!([:linux, :name])}",
      runs_on: Config.fetch!([:linux, :runs_on])
      steps: [
        checkout(),
        check_code_format(),
        lint_code()
      ]
    end

    defp checkout do
      [
        name: "Checkout",
        uses: "actions/checkout@v4"
      ]
    end

    defp lint_code do
      case Project.has_dep?(:credo) do
        false ->
          :skip

        true ->
          [
            name: "Lint code",
            run: mix(:credo, strict: true, env: :test)
          ]
      end
    end

    defp check_code_format do
      case Config.get(:check_code_format, true) do
        false ->
          :skip

        true ->
          [
            name: "Check code format",
            run: mix(:format, check_formatted: true, env: :test)
          ]
      end
    end
  end
  ```
  """

  alias GitHubActions.ConvCase

  defmacro __using__(_opts) do
    quote do
      import GitHubActions.Workflow
      import GitHubActions.Mix
      import GitHubActions.Sigils

      alias GitHubActions.Config
      alias GitHubActions.Project
      alias GitHubActions.Version
      alias GitHubActions.Versions
    end
  end

  @doc """
  Evaluates a workflow script and returns the workflow data structure.
  """
  @spec eval(Path.t()) :: {:ok, term()} | :error
  def eval(file) do
    with {:ok, module} <- compile(file),
         {:ok, workflow} <- workflow(module) do
      {:ok, map(workflow)}
    end
  end

  defp workflow(module) do
    case function_exported?(module, :workflow, 0) do
      true -> {:ok, module.workflow()}
      false -> {:error, :workflow}
    end
  end

  defp compile(file) do
    case file |> File.read!() |> Code.eval_string([], file: file) do
      {{:module, module, _bin, _meta}, _bind} -> {:ok, module}
      _else -> :error
    end
  end

  defp map({_key, :skip}), do: :skip

  defp map({key, value}) when is_tuple(value) do
    {ConvCase.to_kebab(key), value}
  end

  defp map({key, value}) do
    {ConvCase.to_kebab(key), map(value)}
  end

  defp map(workflow) when is_list(workflow) do
    workflow
    |> Enum.reduce([], fn item, acc ->
      case map(item) do
        :skip -> acc
        value -> [value | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp map(:skip), do: :skip

  defp map(value), do: to_string(value)
end
