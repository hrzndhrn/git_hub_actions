defmodule GitHubActions.WorkflowTest do
  use ExUnit.Case

  import Prove

  alias GitHubActions.Config
  alias GitHubActions.Workflow

  setup do
    Config.read("priv/config.exs")
  end

  describe "eval/1" do
    prove "simple workflow",
          Workflow.eval("test/fixtures/workflow_simple.exs") ==
            {:ok, [name: "CI"]}

    prove "workflow with jobs",
          Workflow.eval("test/fixtures/workflow_jobs.exs") ==
            {:ok,
             [
               name: "CI",
               env: [GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"],
               jobs: [
                 linux: [
                   name: """
                   Test on Ubuntu \
                   (Elixir ${{ matrix.elixir }}, \
                   OTP ${{ matrix.otp }})\
                   """,
                   "runs-on": "ubuntu-20.04"
                 ]
               ]
             ]}

    prove "workflow matrix",
          Workflow.eval("test/fixtures/workflow_matrix.exs") ==
            {
              :ok,
              [
                name: "CI",
                env: [GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"],
                jobs: [
                  linux: [
                    name: "Test on Ubuntu (Elixir ${{ matrix.elixir }}, OTP ${{ matrix.otp }})",
                    "runs-on": "ubuntu-20.04",
                    strategy: [
                      matrix: [
                        elixir: [
                          "1.10.4",
                          "1.11.4",
                          "1.12.3",
                          "1.13.4",
                          "1.14.5",
                          "1.15.8",
                          "1.16.3",
                          "1.17.3",
                          "1.18.0"
                        ],
                        otp: ["21.3", "22.3", "23.3", "24.3", "25.3", "26.2", "27.2"],
                        exclude: [
                          [elixir: "1.10.4", otp: "24.3"],
                          [elixir: "1.10.4", otp: "25.3"],
                          [elixir: "1.10.4", otp: "26.2"],
                          [elixir: "1.10.4", otp: "27.2"],
                          [elixir: "1.11.4", otp: "25.3"],
                          [elixir: "1.11.4", otp: "26.2"],
                          [elixir: "1.11.4", otp: "27.2"],
                          [elixir: "1.12.3", otp: "21.3"],
                          [elixir: "1.12.3", otp: "25.3"],
                          [elixir: "1.12.3", otp: "26.2"],
                          [elixir: "1.12.3", otp: "27.2"],
                          [elixir: "1.13.4", otp: "21.3"],
                          [elixir: "1.13.4", otp: "26.2"],
                          [elixir: "1.13.4", otp: "27.2"],
                          [elixir: "1.14.5", otp: "21.3"],
                          [elixir: "1.14.5", otp: "22.3"],
                          [elixir: "1.14.5", otp: "27.2"],
                          [elixir: "1.15.8", otp: "21.3"],
                          [elixir: "1.15.8", otp: "22.3"],
                          [elixir: "1.15.8", otp: "23.3"],
                          [elixir: "1.15.8", otp: "27.2"],
                          [elixir: "1.16.3", otp: "21.3"],
                          [elixir: "1.16.3", otp: "22.3"],
                          [elixir: "1.16.3", otp: "23.3"],
                          [elixir: "1.16.3", otp: "27.2"],
                          [elixir: "1.17.3", otp: "21.3"],
                          [elixir: "1.17.3", otp: "22.3"],
                          [elixir: "1.17.3", otp: "23.3"],
                          [elixir: "1.17.3", otp: "24.3"],
                          [elixir: "1.18.0", otp: "21.3"],
                          [elixir: "1.18.0", otp: "22.3"],
                          [elixir: "1.18.0", otp: "23.3"],
                          [elixir: "1.18.0", otp: "24.3"]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            }

    prove "workflow steps",
          Workflow.eval("test/fixtures/workflow_steps.exs") ==
            {:ok,
             [
               name: "CI",
               env: [GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"],
               jobs: [
                 linux: [
                   name: """
                   Test on Ubuntu (\
                   Elixir ${{ matrix.elixir }}, \
                   OTP ${{ matrix.otp }})\
                   """,
                   "runs-on": "ubuntu-20.04",
                   steps: [
                     [name: "Checkout", uses: "actions/checkout@v4"]
                   ]
                 ]
               ]
             ]}

    prove "default workflow",
          Workflow.eval("priv/default.exs") ==
            {
              :ok,
              [
                name: "CI",
                env: [GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"],
                on: ["pull_request", "push"],
                jobs: [
                  linux: [
                    name: "Test on Ubuntu (Elixir ${{ matrix.elixir }}, OTP ${{ matrix.otp }})",
                    "runs-on": "ubuntu-20.04",
                    strategy: [
                      matrix: [
                        include: [
                          [elixir: "1.18.0", otp: "27.2"],
                          [elixir: "1.18.0", otp: "26.2"],
                          [elixir: "1.18.0", otp: "25.3"],
                          [elixir: "1.17.3", otp: "25.3"],
                          [elixir: "1.16.3", otp: "24.3"],
                          [elixir: "1.15.8", otp: "24.3"],
                          [elixir: "1.14.5", otp: "23.3"],
                          [elixir: "1.13.4", otp: "22.3"]
                        ]
                      ]
                    ],
                    steps: [
                      [name: "Checkout", uses: "actions/checkout@v4"],
                      [
                        name: "Setup Elixir",
                        uses: "erlef/setup-beam@v1",
                        with: [
                          "elixir-version": "${{ matrix.elixir }}",
                          "otp-version": "${{ matrix.otp }}"
                        ]
                      ],
                      [
                        name: "Restore deps",
                        uses: "actions/cache@v4",
                        with: [
                          path: "deps",
                          key:
                            "deps-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [
                        name: "Restore _build",
                        uses: "actions/cache@v4",
                        with: [
                          path: "_build",
                          key:
                            "_build-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [
                        name: "Restore test/support/plts",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        uses: "actions/cache@v4",
                        with: [
                          path: "test/support/plts",
                          key:
                            "test/support/plts-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [name: "Get dependencies", run: "mix deps.get"],
                      [name: "Compile dependencies", run: "MIX_ENV=test mix deps.compile"],
                      [
                        name: "Compile project",
                        run: "MIX_ENV=test mix compile --warnings-as-errors"
                      ],
                      [
                        name: "Check unused dependencies",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix deps.unlock --check-unused"
                      ],
                      [
                        name: "Check code format",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix format --check-formatted"
                      ],
                      [
                        name: "Lint code",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix credo --strict"
                      ],
                      [
                        name: "Run tests",
                        if: "${{ !(matrix.elixir == '1.18.0' && matrix.otp == '27.2') }}",
                        run: "mix test"
                      ],
                      [
                        name: "Run tests with coverage",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix coveralls.github"
                      ],
                      [
                        name: "Static code analysis",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix dialyzer --format github --force-check"
                      ]
                    ]
                  ]
                ]
              ]
            }

    prove "exclude workflow",
          Workflow.eval("priv/exclude.exs") ==
            {
              :ok,
              [
                name: "CI",
                env: [GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"],
                on: ["pull_request", "push"],
                jobs: [
                  linux: [
                    name: "Test on Ubuntu (Elixir ${{ matrix.elixir }}, OTP ${{ matrix.otp }})",
                    "runs-on": "ubuntu-20.04",
                    strategy: [
                      matrix: [
                        elixir: ["1.13.4", "1.14.5", "1.15.8", "1.16.3", "1.17.3", "1.18.0"],
                        otp: ["22.3", "23.3", "24.3", "25.3", "26.2", "27.2"],
                        exclude: [
                          [elixir: "1.13.4", otp: "26.2"],
                          [elixir: "1.13.4", otp: "27.2"],
                          [elixir: "1.14.5", otp: "22.3"],
                          [elixir: "1.14.5", otp: "27.2"],
                          [elixir: "1.15.8", otp: "22.3"],
                          [elixir: "1.15.8", otp: "23.3"],
                          [elixir: "1.15.8", otp: "27.2"],
                          [elixir: "1.16.3", otp: "22.3"],
                          [elixir: "1.16.3", otp: "23.3"],
                          [elixir: "1.16.3", otp: "27.2"],
                          [elixir: "1.17.3", otp: "22.3"],
                          [elixir: "1.17.3", otp: "23.3"],
                          [elixir: "1.17.3", otp: "24.3"],
                          [elixir: "1.18.0", otp: "22.3"],
                          [elixir: "1.18.0", otp: "23.3"],
                          [elixir: "1.18.0", otp: "24.3"]
                        ]
                      ]
                    ],
                    steps: [
                      [name: "Checkout", uses: "actions/checkout@v4"],
                      [
                        name: "Setup Elixir",
                        uses: "erlef/setup-beam@v1",
                        with: [
                          "elixir-version": "${{ matrix.elixir }}",
                          "otp-version": "${{ matrix.otp }}"
                        ]
                      ],
                      [
                        name: "Restore deps",
                        uses: "actions/cache@v4",
                        with: [
                          path: "deps",
                          key:
                            "deps-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [
                        name: "Restore _build",
                        uses: "actions/cache@v4",
                        with: [
                          path: "_build",
                          key:
                            "_build-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [
                        name: "Restore test/support/plts",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        uses: "actions/cache@v4",
                        with: [
                          path: "test/support/plts",
                          key:
                            "test/support/plts-${{ runner.os }}-${{ matrix.elixir }}-${{ matrix.otp }}-${{ hashFiles(format('{0}{1}', github.workspace, '/mix.lock')) }}-${{ steps.setup-beam.outputs.setup-beam-version }}"
                        ]
                      ],
                      [name: "Get dependencies", run: "mix deps.get"],
                      [name: "Compile dependencies", run: "MIX_ENV=test mix deps.compile"],
                      [
                        name: "Compile project",
                        run: "MIX_ENV=test mix compile --warnings-as-errors"
                      ],
                      [
                        name: "Check unused dependencies",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix deps.unlock --check-unused"
                      ],
                      [
                        name: "Check code format",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix format --check-formatted"
                      ],
                      [
                        name: "Lint code",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix credo --strict"
                      ],
                      [
                        name: "Run tests",
                        if: "${{ !(matrix.elixir == '1.18.0' && matrix.otp == '27.2') }}",
                        run: "mix test"
                      ],
                      [
                        name: "Run tests with coverage",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix coveralls.github"
                      ],
                      [
                        name: "Static code analysis",
                        if: "${{ matrix.elixir == '1.18.0' && matrix.otp == '27.2' }}",
                        run: "mix dialyzer --format github --force-check"
                      ]
                    ]
                  ]
                ]
              ]
            }
  end
end
