# MKU and MCII: first implementation milestone

This repository is the home of the MKU language and MCII compiler. The current compiler source is `MCII.asm`: a Linux x86-64 NASM program that reads a small MKU source subset and emits NASM assembly. It is not yet a complete self-hosting compiler or a general-purpose OS/AI language.

## Build and smoke-test

Requirements for this milestone: Linux x86-64, NASM, and GNU `ld`.

```sh
make
make test
make example
```

The compiler command is:

```sh
build/mcii input.mku output.asm
nasm -f elf64 output.asm -o output.o
ld output.o -o output
./output
```

## Current supported subset

The existing compiler supports simple `print` statements (string or integer expression), `let name = arithmetic_expression`, variables, parentheses, and integer arithmetic (`+`, `-`, `*`, `/`, `%`). Comments begin with `#`. See `examples/hello.mku` and `docs/MKU_SPEC_v0.1.md`.

The compiler emits Linux x86-64 assembly. NASM and the linker are build-time tools; the present implementation is therefore not yet a standalone toolchain. `if`, loops, functions, strings as values, modules, type checking, and other features are future work and should only be called supported after implementation and tests exist.

## Development direction

1. Establish reproducible build and regression tests (this milestone).
2. Replace ad-hoc source scanning with a lexer and parser while keeping the compiler in assembly.
3. Add diagnostics and a documented grammar; test every feature.
4. Add control flow, functions, and a defined runtime/ABI.
5. Expand standard libraries through explicit, permission-conscious APIs.
6. Explore self-hosting only after the compiler can reliably build useful programs.

Performance claims need benchmarks against named versions, workloads, and targets. “Faster than Rust” is an aspiration, not a result established by this prototype. The project is free/open-source only to the extent its maintainers choose and publish a license; no license is implied by this README.
