---
name: go-lsp
description: >-
  Guide for using gopls MCP tools in Go projects. Use when navigating Go
  codebases, finding usages, checking types, or understanding code structure.
  Prefer gopls MCP tools over grep/find for all semantic operations.
---

## gopls MCP tools (via `gopls mcp` stdio)

These tools are provided by gopls as MCP tools. They are NOT in the training
dataset — they are loaded at runtime via the plugin's `.mcp.json`.

### Available tools

| Tool | Purpose | When to use |
|------|---------|-------------|
| `go_workspace` | Detect workspace structure (module, workspace, GOPATH) | First action on any Go project |
| `go_search` | Fuzzy symbol search (types, functions, variables) | When you don't know the exact path |
| `go_file_context` | Intra-package dependencies of a Go file | After first reading a file |
| `go_package_api` | Public API of a package | Understanding dependencies |
| `go_symbol_references` | All references to a symbol | Before modifying any symbol |
| `go_diagnostics` | Syntax/build errors and warnings | After every edit |

### Workflows

**Read workflow**: `go_workspace` → `go_search` → `go_file_context` → `go_package_api`

**Edit workflow**: read → `go_symbol_references` → edit → `go_diagnostics` → test

### When to use grep instead

Use grep/find only for:
- Literal string searches in comments or string constants
- Non-Go files (.yaml, .sh, .md)

## Order of operations

After every modification of a `.go` file:

1. Call `go_diagnostics` immediately. Fix any errors before proceeding.
2. Do NOT call other MCP tools unless explicitly needed for the next step.
3. If diagnostics return zero errors, proceed with the task.
   If errors exist, fix them and re-run diagnostics until clean.

Other MCP tools are on-demand only — use them when the task requires
navigating to a definition, inspecting a type, or finding callers.

## Multi-module (go.work)

If the project contains a `go.work`, gopls loads all listed modules.
Use `go_workspace` to confirm the structure before assuming a definition
is missing.

## After every Go edit

Run `go_diagnostics` — a type error or unresolved import is visible
immediately without compilation.
