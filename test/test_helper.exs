Code.compiler_options(ignore_module_conflict: true)

Code.compile_file("test/git_hub_actions_case.exs")

ExUnit.start()
