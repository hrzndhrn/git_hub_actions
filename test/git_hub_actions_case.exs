defmodule GitHubActionsCase do
  use ExUnit.CaseTemplate

  import ExUnit.CaptureIO
  import Mock

  @dir ".gha"
  @fixtures "test/fixtures"
  @tmp "test/tmp"
  @home Path.join(@tmp, "home")
  @config "config.exs"
  @defaults [workflow: :default, config: :default, output: :default]

  using do
    {module, default} =
      case __CALLER__.module do
        Mix.Tasks.GhaTest -> {Mix.Tasks.Gha, []}
        _else -> {GitHubActions, @defaults}
      end

    quote do
      import GitHubActionsCase

      def assert_run(file, opts \\ unquote(default)) do
        assert capture_io(fn -> unquote(module).run(opts) end) =~
                 ~r|creating.+test/tmp/#{file}|

        result =
          file
          |> tmp()
          |> File.read!()

        expected = file |> fixture() |> File.read!()

        if result != expected,
          do: IO.puts("\nUnexpected result. Should be:\nfile: #{file},\n#{result}\n")

        assert result == expected
      end
    end
  end

  setup_with_mocks([
    {System, [:passthrough], [user_home!: fn -> @home end]}
  ]) do
    # Create local .gha dir for config.
    File.mkdir(@dir)
    File.mkdir_p(Path.join(@home, @dir))

    on_exit(fn ->
      File.rm_rf!(@dir)
      File.rm_rf!(@home)

      @tmp
      |> File.ls!()
      |> Enum.each(fn
        ".keep" -> :ok
        file -> @tmp |> Path.join(file) |> File.rm!()
      end)
    end)

    :ok
  end

  def tmp, do: @tmp

  def tmp(file), do: Path.join(@tmp, file)

  def fixture(file), do: Path.join(@fixtures, file)

  def local(file), do: Path.join(@dir, file)

  def local_config(term) do
    write_config(Path.join(@dir, @config), term)
  end

  def global_config(term) do
    write_config(Path.join([@home, @dir, @config]), term)
  end

  defp write_config(path, term) do
    File.write!(path, """
    import GitHubActions.Config
    config(#{inspect(term)})
    """)
  end

  def opts, do: @defaults

  def opts(opts), do: Keyword.merge(@defaults, opts)
end
