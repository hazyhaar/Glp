---
name: go-lsp
description: >-
  Guide for using gopls LSP tools in Go projects. Use when navigating Go
  codebases, finding usages, checking types, or understanding code structure.
  Prefer LSP over grep/find for all semantic operations.
---

## Modes of operation

gopls can be used in two modes. The available operations differ:

### Integrated LSP (VS Code, Claude Code with LSP plugin)

When gopls runs as a persistent language server, all LSP protocol
operations are available as tools:

- `findReferences` — all usages of a function or type
- `goToDefinition` — jump to a definition
- `hover` — type and doc info without reading the file
- `documentSymbol` — list symbols in a file
- `getDiagnostics` — current errors and warnings

### CLI mode (gopls command-line)

When invoking gopls directly from the shell, only a subset of
operations is available:

| CLI command | Equivalent LSP operation |
|---|---|
| `gopls check <file>` | `getDiagnostics` |
| `gopls definition <file>:<line>:<col>` | `goToDefinition` |
| `gopls references <file>:<line>:<col>` | `findReferences` |
| `gopls symbols <file>` | `documentSymbol` |

**`hover` is NOT available as a CLI command** (gopls v0.17+). In CLI
mode, use `gopls definition` to get the full signature including the
doc comment, which provides equivalent information.

## When to use LSP instead of grep

Always use LSP tools (or their CLI equivalents) for:
- Finding all usages of a function or type → `findReferences` / `gopls references`
- Jumping to a definition → `goToDefinition` / `gopls definition`
- Understanding a type without reading the file → `hover` (LSP only) / `gopls definition` (CLI)
- Listing symbols in a file → `documentSymbol` / `gopls symbols`
- Getting current errors → `getDiagnostics` / `gopls check`

Use grep/find only for:
- Literal string searches in comments or string constants
- Non-Go files (.yaml, .sh, .md)

## Ordre des opérations

After every modification of a `.go` file:

1. Call `getDiagnostics` (or `gopls check`) immediately. Fix any errors before proceeding.
2. Do NOT call other LSP tools (`findReferences`, `hover`,
   `goToDefinition`, `documentSymbol`) unless explicitly needed for
   the next step.
3. If diagnostics return zero errors, proceed with the task.
   If errors exist, fix them and re-run diagnostics until clean.

Other LSP tools are on-demand only — use them when the task requires
navigating to a definition, inspecting a type, or finding callers.

## Multi-module (go.work)

If the project contains a `go.work`, gopls loads all listed modules.

`goToDefinition` can return "not found" on a symbol from a secondary
module that gopls has not yet indexed. When this happens:

1. Identify a `.go` file in the target module (any file works).
2. Call `documentSymbol` on that file — this forces gopls to index
   the module.
3. Retry `goToDefinition` on the original symbol.

Do not fall back to grep. The index-then-retry sequence resolves the
issue in all cases where the symbol actually exists.
