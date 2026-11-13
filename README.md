# MKU and MCII

MKU is an experimental programming-language project. MCII is its compiler project. The project is being built incrementally; it does not yet provide a complete general-purpose language, self-hosting compiler, operating-system development kit, or AI framework.

## Current compiler milestone

`MCII.asm` is the current Linux x86-64 NASM bootstrap compiler. It reads a deliberately small MKU subset and emits NASM source. `MCII.ci` is the canonical project/design manifest for the intended MCII compiler; it is **not executable compiler source yet**. The `.ci` extension does not itself make the compiler independent of assembly.

Current subset: integer `let` declarations, `print` of strings or integer expressions, variables, parentheses, and integer arithmetic (`+`, `-`, `*`, `/`, `%`). The actual supported syntax is described in `docs/MKU_SPEC_v0.1.md`.

## Build and test

Requirements: Linux x86-64, NASM, GNU `ld`, and Make.

```sh
make
make test
make example
```

Manual use:

```sh
build/mcii examples/hello.mku build/hello.asm
nasm -f elf64 build/hello.asm -o build/hello.o
ld build/hello.o -o build/hello
./build/hello
```

## Bootstrap and independence

A compiler must run on some existing machine before it can compile itself. This project uses the existing NASM toolchain for its first bootstrap stage. The long-term goal is to move compiler implementation into MKU and make it self-hosting, while retaining a documented bootstrap path. Self-hosting means the MKU compiler can compile its own source; it does not mean the toolchain has no host, linker, or target-platform requirements.

The phrase “faster than Rust” is not a measured result. Any performance comparison needs published compiler versions, target hardware, workloads, and repeatable benchmarks. No license is implied until a license file is added.

## Planned milestones

1. Keep the current subset buildable and add regression tests.
2. Replace direct scanning with a lexer, parser, and useful source diagnostics.
3. Add tested control flow and functions to the language and native code generator.
4. Define types, calling convention, memory model, and a small standard library.
5. Implement the compiler in MKU and verify bootstrap by compiling it twice and comparing outputs.
6. Add additional targets and libraries only with explicit safety and capability rules.
