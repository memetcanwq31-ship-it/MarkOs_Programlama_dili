# MCII implementation roadmap

This roadmap favors a small compiler that is correct and testable over a large list of unimplemented features.

## Stage 0 — reproducible bootstrap

- Keep `MCII.asm` as the explicitly documented x86-64 NASM bootstrap.
- Build with `make`; run `make test` and `make example`.
- Record what the compiler actually supports in the MKU spec.

## Stage 1 — compiler correctness

- Fix and test input/output handling, buffer bounds, identifier limits, and error exits.
- Add source locations to diagnostics.
- Add regression cases for arithmetic precedence, parentheses, undefined names, malformed expressions, and multiple statements.
- Reject unsupported syntax consistently; do not generate misleading output.

## Stage 2 — language foundations

Implement, in this order, with tests and updated documentation for each feature:

1. `goster` and `olsun` as deliberate MKU spellings for output and declaration.
2. Comparisons and booleans.
3. `eger`/`degilse` conditional control flow.
4. `tekrar` loop, including correct condition evaluation and termination.
5. `gorev` functions, parameters, calls, and `dondur` returns.
6. Strings as values and safe output/input routines.

The current compiler does not yet support those proposed forms. Keep the v0.1 syntax (`print`, `let`) working until compatibility policy is documented.

## Stage 3 — usable systems language

- Specify integer widths, signedness, calling convention, stack/register usage, and error model.
- Add typed pointers and memory operations only with clear safety rules.
- Add modules and a small standard library with deterministic imports.
- Keep shell and network functionality opt-in and explicit; library APIs must not silently scan or modify unrelated systems.
- Add cross-platform targets only with target-specific tests.

## Stage 4 — self-hosting

- Implement MCII's lexer/parser/code generator in MKU after the language can express it.
- Build compiler version 1 with the bootstrap compiler, then use version 1 to compile itself.
- Run all tests on both outputs and document reproducible bootstrap steps before claiming self-hosting.

## Release quality bar

A feature is “supported” only if there is a specification, an implementation, positive and negative regression tests, and an example. Performance claims require reproducible benchmarks. Add a repository license before claiming an open-source license.
