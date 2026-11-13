# MKU v0.1 language subset

This document describes only the subset currently implemented by `MCII.asm`. It deliberately does not promise syntax that the compiler cannot yet compile.

## Source format

- Source files use `.mku`.
- `#` begins a comment through the end of the line.
- Statements are separated by whitespace/newlines.
- The current compiler is for Linux x86-64 and emits NASM syntax.

## Statements

```mku
print "Hello"
let answer = 6 * 7
print answer
```

`print` accepts a quoted string or integer expression. `let` declares an integer variable. The current implementation also permits arithmetic expressions with integer literals, previously declared variables, parentheses, and `+ - * / %`.

## Expression precedence

From highest to lowest:

1. Parenthesized expressions, integer literals, variables
2. `*`, `/`, `%`
3. `+`, `-`

The current compiler uses signed division for `/` and `%`. Division by zero is not yet given a language-level diagnostic.

## Explicit non-features in v0.1

There is no supported `if`, loop, function, array, string variable, module/import, input, network, filesystem, or crypto API yet. Do not rely on these until implemented and covered by tests. Security-sensitive APIs must be designed with authorization and safe defaults in mind.

## Compiler pipeline today

`MCII.asm` reads source, parses the supported subset directly, and emits assembly text. The user then invokes NASM and `ld` to produce a Linux executable. A lexer/AST, portable targets, a standard library, self-hosting, and claims of performance over Rust remain future goals.
