# MCII bootstrap and self-hosting plan

## What “independent” means here

MKU can have its own syntax, compiler, runtime, libraries, and build workflow. It cannot appear without a bootstrap: the first compiler must be assembled, compiled, or interpreted using an existing tool on a host machine. MCII currently uses NASM source (`MCII.asm`) as that bootstrap. The goal is to replace the compiler implementation with MKU source over successive stages, not to claim that a source-file extension removes the bootstrap dependency.

## File roles

- `MCII.asm`: current executable compiler source, written in x86-64 NASM.
- `MCII.ci`: compiler-project manifest and intended architecture; currently design metadata, not executable code.
- `*.mku`: MKU programs.
- `docs/MKU_SPEC_v0.1.md`: the currently implemented language subset.

## Staged bootstrap

1. Make the existing compiler reproducibly build and test on Linux x86-64.
2. Add proper tokenization, parsing, diagnostics, and one regression test per feature.
3. Expand the language and compiler in small, testable milestones.
4. Once MKU can express the compiler's needed data structures and control flow, implement a second compiler in MKU (MCII-1).
5. Use the existing bootstrap compiler to build MCII-1; then use MCII-1 to compile itself (MCII-2).
6. Compare outputs and run the complete test suite before describing MCII as self-hosting.
7. Keep the bootstrap toolchain documented for clean machines and future targets.

## Quality bar

- Never mark a feature supported without a test.
- Reject unsupported syntax with a source location rather than emitting plausible but incorrect assembly.
- Keep generated code deterministic where practical.
- Treat network, shell, filesystem, and process operations as explicit capabilities; avoid silently granting arbitrary access.
- Publish reproducible benchmarks before making speed claims.
- Add a license before describing the repository as legally open-source.
