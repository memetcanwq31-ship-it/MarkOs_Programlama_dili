# MKU Standard Library — proposal

This catalogue defines the intended names and boundaries for MKU's standard library. It is a design document, not a claim that the current MCII bootstrap supports `import` or implements these modules. Current compiler support remains documented in `docs/MKU_SPEC_v0.1.md`.

## Import syntax proposal

```mku
import core.text
import core.math as math

start {
    goster(text.upper("selam"))
    goster(math.add(20, 22))
}
```

Rules proposed for the language:

- `import package.module` makes the final module name available.
- `import package.module as alias` makes the given alias available.
- Imports are resolved from a documented standard-library registry and the project's module paths; no arbitrary code is executed just because a name is imported.
- Unknown modules and names should be compile-time errors with file/line/column locations.
- Module access should be explicit. Network, filesystem, process, and device capabilities must not be silently granted.
- Until the feature is implemented and tested in MCII, the example above is design-only and will not compile with the current compiler.

## Proposed modules

| Import | Planned purpose | Safety / status |
|---|---|---|
| `core.text` | UTF-8 length, search, trim, case conversion, formatting | Pure operations; proposed |
| `core.math` | integer arithmetic helpers, min/max, checked operations | Pure operations; proposed |
| `core.collections` | list, map, set, iteration helpers | In-memory only; proposed |
| `core.convert` | explicit numeric/text conversions and parsing | Checked conversions; proposed |
| `core.option` | optional values and result/error values | No hidden exceptions; proposed |
| `core.time` | monotonic clock and duration arithmetic | Clock access is explicit; proposed |
| `core.random` | random bytes and bounded random values | Document secure vs. non-secure source; proposed |
| `crypto.hash` | SHA-256 and other clearly identified digest APIs | Hashing only; never call a digest encryption; proposed |
| `crypto.random` | operating-system random bytes | Requires OS capability; proposed |
| `io.console` | terminal output and input | Explicit standard input/output; proposed |
| `io.file` | read/write files under granted paths | Capability-scoped; no implicit unrestricted access; proposed |
| `system.info` | OS/architecture/version information | Read-only; proposed |
| `system.process` | process metadata and controlled process creation | Explicit permissions; proposed |
| `net.client` | client-side DNS/HTTP/socket APIs | Explicit destination and permission; proposed |
| `net.inspect` | diagnostics for systems the user owns or is authorized to test | No stealth, exploitation, or broad scanning defaults; proposed |
| `ai.tensor` | tensor shapes and CPU operations | Experimental design only; proposed |
| `ai.model` | model loading/inference interfaces | Backend and hardware requirements to be specified; proposed |
| `os.memory` | allocation and memory-region interfaces | Unsafe operations must be explicit and carefully documented; proposed |
| `os.device` | device and platform interfaces | Target-specific, permission-controlled; proposed |

## Implementation order

1. Implement lexer/parser support for `import`, aliases, and module-qualified names.
2. Start with pure modules: `core.text`, `core.math`, `core.convert`.
3. Add deterministic module resolution and negative tests for unknown imports.
4. Add console/file APIs behind explicit capabilities.
5. Add networking and platform APIs only after permission, error, and resource-lifetime rules are specified.
6. Add AI interfaces only after the value/type system and backend ABI are defined.

A module becomes supported only when its API is specified, implemented in the compiler/runtime, and covered by tests. Keep this table updated as implementation changes.
