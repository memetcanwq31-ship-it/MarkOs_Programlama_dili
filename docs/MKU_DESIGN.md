# MKU language: goals and first design

MKU is intended to be a small, approachable systems language with its own syntax, compiler, runtime, and standard library. The project is experimental: this document separates the long-term design from what MCII currently compiles.

## Design goals

- **Readable first:** a beginner should be able to understand a short program without learning a large framework.
- **Own identity:** MKU defines its syntax and semantics; it is not Python syntax with a new extension.
- **Systems-capable:** the long-term design includes explicit types, memory and ABI rules, and native targets.
- **Predictable:** explicit errors, deterministic builds where practical, and no hidden network, shell, or filesystem actions.
- **Incremental:** each language feature becomes supported only when MCII implements it and tests cover it.
- **Open development:** use a project license before describing the code as legally open-source.

## Current implemented subset (MCII bootstrap)

The current compiler is the NASM x86-64 source `MCII.asm`. Its documented subset is in `MKU_SPEC_v0.1.md`: `print` of a string or integer expression, `let` integer declarations, variables, parentheses, and integer arithmetic. It emits NASM source for Linux x86-64; NASM and `ld` are still needed to build an executable.

Runnable example:

```mku
print "Selam, MKU!"
let cevap = (6 + 7) * 3
print cevap
```

Run it with `make example` after installing the documented build requirements.

## Proposed beginner-facing syntax

This is a design proposal, not yet accepted by the current compiler. Use ASCII keywords in source for easy typing and reliable tool compatibility; Turkish explanations remain welcome in comments and docs.

```mku
use core.text

start {
    olsun cevap = (6 + 7) * 3
    goster "Selam MKU!"
    goster cevap

    eger cevap == 39 {
        goster "Hesap dogru."
    } degilse {
        goster "Tekrar dene."
    }
}
```

Proposed keyword mapping: `goster` (output), `olsun` (immutable/local declaration, final mutability rules TBD), `eger`/`degilse` (branch), `tekrar` (loop), `gorev` (function), `dondur` (return), and `use` (module). These names must not be presented as compiler-supported until MCII has tests for them. The compiler should reject unknown constructs with file/line/column diagnostics rather than silently accepting them.

## Semantics to settle before expanding syntax

1. Values and types: signed integer widths, booleans, UTF-8 strings, arrays, and explicit conversions.
2. Mutability: choose a clear rule for `olsun` and add a separate mutable declaration only if needed.
3. Scope: lexical scopes, function parameters, return types, and shadowing rules.
4. Runtime/ABI: stack layout, calling convention, panic/error behavior, and ownership/memory strategy.
5. Modules: deterministic module resolution, standard-library boundaries, and explicit capabilities for I/O.
6. Targets: begin with Linux x86-64 ELF; specify other targets separately.

## Performance and independence

“Faster than Rust” is a hypothesis, not a feature. Publish repeatable benchmarks with compiler versions, target hardware, inputs, and commands before making comparative claims. A self-hosted compiler still needs a documented bootstrap compiler and host toolchain; self-hosting does not mean “no tools or platform dependencies.”
