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

## Multi-module (go.work)

If the project contains a `go.work`, gopls loads all listed modules.
Check with `documentSymbol` on a file from a secondary module before
assuming a definition is missing.

## After every Go edit

gopls returns diagnostics automatically after modification.
Read them before continuing — a type error or unresolved import
is visible immediately without compilation.
