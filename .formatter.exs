# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  normalize_charlists_as_sigils: false,
  locals_without_parens: [config: 1],
  import_deps: [:prove]
]
