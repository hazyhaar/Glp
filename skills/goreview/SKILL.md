---
name: goreview
description: >-
  Comprehensive Go code review combining LSP diagnostics, external linters,
  vulnerability scanning, and semantic review patterns. Use for PR reviews,
  pre-commit checks, or audit sessions on Go projects.
---

## Overview

This skill orchestrates a full Go code review in three passes. It builds on
the plugin's LSP integration (gopls) and sibling skills, then adds external
tooling and a pattern-based checklist.

**Depends on plugin skills:** `go-lsp` (LSP navigation), `go-modern` (idiom
detection), `go-mod` (dependency audit).

## Prerequisites (external tools)

Check availability before starting. Skip any tool that is missing — report
it as a gap at the end of the review.

| Tool | Install | Purpose |
|------|---------|---------|
| `golangci-lint` | `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` | Meta-linter (~100 linters) |
| `govulncheck` | `go install golang.org/x/vuln/cmd/govulncheck@latest` | Known CVEs in dependencies |
| `deadcode` | `go install golang.org/x/tools/cmd/deadcode@latest` | Unreachable exported functions |
| `nilaway` | `go install go.uber.org/nilaway/cmd/nilaway@latest` | Inter-procedural nil-safety |

## Pass 1 — Automated diagnostics

Run these in parallel when possible. Collect all output before analysis.

### 1a. gopls diagnostics (via go-lsp skill)

Use `getDiagnostics` on every modified file. This covers:
- Compilation errors and type mismatches
- `staticcheck` warnings (enabled in `.lsp.json`)
- `modernize` analyzer suggestions
- `nilness` basic nil checks
- `unusedparams`, `unusedwrite` detection

**CLI fallback** (when LSP is not available as an integrated tool):

```bash
gopls check ./path/to/modified_file.go
```

If gopls is not available at all, fall back to standalone tools:

```bash
go vet ./...
staticcheck ./...
```

These cover compilation errors, vet checks, and staticcheck analysis.
They do not cover `modernize`, `unusedwrite`, or LSP hints, but provide
a reasonable baseline for Pass 1a.

### 1b. golangci-lint (delta mode)

```bash
golangci-lint run --new-from-rev=main --out-format=json ./...
```

Key linters beyond what gopls provides:
- **gocritic** — opinionated patterns (sloppyLen, dupSubExpr, hugeParam)
- **gosec** — OWASP: SQL injection, hardcoded creds, weak crypto
- **bodyclose** — unclosed HTTP response bodies
- **sqlclosecheck** — unclosed sql.Rows and sql.Stmt
- **contextcheck** — missing context propagation
- **exhaustive** — non-exhaustive switch/map on enum types
- **errname** — error type naming conventions
- **prealloc** — slice preallocation opportunities

If `.golangci.yml` exists in the project, respect it. Do not override
project-level linter configuration.

### 1c. govulncheck

```bash
govulncheck ./...
```

Report any CVE found with severity and affected call path.
Flag as CRITICAL if the vulnerable code path is actually reachable.

## Pass 2 — Deep analysis

Run on modified files and their direct dependents.

### 2a. nilaway

```bash
nilaway ./...
```

Reports inter-procedural nil pointer risks that gopls `nilness` misses —
nil flowing through function boundaries, interface satisfaction, channel
receives.

### 2b. deadcode

```bash
deadcode -test ./...
```

Flag exported functions with zero callers. Distinguish between:
- Truly dead code (candidate for removal)
- Interface implementations (false positives — verify with `findReferences`)
- Entry points (main, init, HTTP handlers registered dynamically)

### 2c. Impact analysis (via go-lsp skill)

For each modified public function or type:
- `findReferences` (or `gopls references` in CLI mode) to list all callers
- `hover` (LSP) or `gopls definition` (CLI) to verify the full signature
  hasn't drifted from callers' expectations
- Flag any caller outside the current PR scope as potential breakage

**CLI fallback** (when LSP is not available):

```bash
gopls references ./path/file.go:<line>:<col>
gopls definition ./path/file.go:<line>:<col>
```

If gopls is unavailable, use `Grep "FuncName"` as a last resort — this
finds textual matches but misses renames and interface satisfaction.

## Pass 3 — Pattern checklist

Review the diff against these patterns. Each pattern is a pass/fail check.
Report violations with file and line reference.

### P1. Error wrapping

Every `if err != nil` block must either:
- Wrap with context: `fmt.Errorf("operation: %w", err)`
- Return a sentinel or domain error
- Handle (log + recover)

Bare `return err` without context is a violation except in trivial wrappers.

### P2. Goroutine lifecycle

Every `go func()` must have a clear shutdown path:
- Context cancellation (`<-ctx.Done()`)
- Done channel or WaitGroup
- Documented in a comment if non-obvious

Goroutines without a shutdown signal are a violation.

### P3. Resource cleanup

Resources (`*os.File`, `*sql.Rows`, `*http.Response.Body`, `net.Conn`)
must be closed via `defer` immediately after acquisition. The defer should
check the close error:

```go
defer func() { _ = f.Close() }()   // acceptable
defer f.Close()                      // acceptable if error is irrelevant
```

Opening a resource without a corresponding defer in the same scope is a
violation.

### P4. Interface compliance

Exported types implementing an interface should have a compile-time check:

```go
var _ Interface = (*Impl)(nil)
```

Missing compile-time check on a type that satisfies a non-trivial interface
is a warning.

### P5. Table-driven tests

Test functions with repeated similar assertions should use `t.Run` +
subtests with a test table. Duplicated test logic without subtests is a
warning.

### P6. Context propagation

- HTTP handlers: extract context from `r.Context()`
- Service methods: accept `ctx context.Context` as first parameter
- Database calls: use `QueryContext`/`ExecContext`, never `Query`/`Exec`

Missing context propagation is a violation.

### P7. Zero-value usefulness

Exported structs should be usable without a constructor when possible.
If a constructor is required, document why. Unexported fields with required
initialization should use functional options or a builder, not bare struct
literals with easy-to-miss fields.

### P8. Concurrent safety

- `sync.Mutex` fields must be unexported
- Document which fields a mutex protects (comment above the mutex)
- No exported mutex, no `sync.Map` when a typed map + mutex suffices
- Channel direction should be constrained in function signatures
  (`<-chan T` or `chan<- T`, not `chan T`)

## Output format

Structure the review as:

```
## Diagnostics (Pass 1)
[gopls findings]
[golangci-lint findings]
[govulncheck findings]

## Deep analysis (Pass 2)
[nilaway findings]
[deadcode findings]
[impact analysis]

## Pattern review (Pass 3)
P1 Error wrapping: PASS / FAIL (details)
P2 Goroutine lifecycle: PASS / FAIL (details)
...

## Summary
- CRITICAL: N (must fix before merge)
- WARNING: N (should fix)
- INFO: N (suggestions)
- Tools missing: [list any unavailable tools]
```
