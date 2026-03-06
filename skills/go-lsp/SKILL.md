---
name: go-lsp
description: >-
  Guide for using gopls LSP tools in Go projects. Use when navigating Go
  codebases, finding usages, checking types, or understanding code structure.
  Prefer LSP over grep/find for all semantic operations.
---

## When to use LSP instead of grep

Always use LSP tools for:
- Finding all usages of a function or type → `findReferences`
- Jumping to a definition → `goToDefinition`
- Understanding a type without reading the file → `hover`
- Listing symbols in a file → `documentSymbol`
- Getting current errors → `getDiagnostics`

Use grep/find only for:
- Literal string searches in comments or string constants
- Non-Go files (.yaml, .sh, .md)

## Ordre des opérations

After every modification of a `.go` file:

1. Call `getDiagnostics` immediately. Fix any errors before proceeding.
2. Do NOT call other LSP tools (`findReferences`, `hover`,
   `goToDefinition`, `documentSymbol`) unless explicitly needed for
   the next step.
3. If `getDiagnostics` returns zero errors, proceed with the task.
   If errors exist, fix them and re-run `getDiagnostics` until clean.

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

## Known limitations

### workspaceSymbol

`workspaceSymbol` returns empty results when the project is a single
module without `go.work`. gopls treats it as a standalone package and
does not populate the workspace index. Use `documentSymbol` per file
instead, or create a `go.work` that lists the module.

### goToImplementation

`goToImplementation` may return "no definition found" on interfaces
when gopls has not fully indexed dependencies. If this happens:

1. Run `getDiagnostics` to ensure the project compiles cleanly.
2. Call `documentSymbol` on a file in the package that contains the
   concrete implementation — this forces indexing.
3. Retry `goToImplementation`.

If it still fails, fall back to `findReferences` on the interface
method and filter for concrete types manually.
