---
name: go-modern
description: >-
  Modern Go idioms guide covering Go 1.21 through 1.26. Activate at the start
  of any Go coding session. Detects Go version from go.mod automatically.
---

## Version detection

Read `go.mod` (directive `go X.Y`) to determine the target version.
Never use features beyond that version.

## Go 1.26 (February 2026)

### Language changes

- `new(expr)` — creates an initialized pointer: `p := new(42)` instead of
  `x := 42; p := &x`. Especially useful for optional pointer fields in
  JSON/protobuf structs.
- Self-referential generics: `type Adder[A Adder[A]] interface{...}` —
  generic types may now refer to themselves in their own type parameter list.

### Performance

- GC Green Tea enabled by default (was experimental in 1.25) — 10-40%
  lower GC overhead for most programs with heavy GC workloads.
- cgo overhead reduced by ~30%.
- Compiler allocates slice backing stores on the stack in more cases.
- Small object allocations up to 30% faster.

### Tooling

- `go fix` completely rewritten — now shares the analysis framework with
  `go vet`. Includes dozens of fixers for modern Go idioms and a
  source-level inliner via `//go:fix inline` directives. Prefer
  `go fix ./...` over manual rewrites when migrating to modern patterns.
- pprof web UI (`-http` flag) opens flame graph view by default.

### New packages

- `crypto/hpke` — Hybrid Public Key Encryption (RFC 9180), including
  post-quantum hybrid KEMs.
- `simd/archsimd` (experimental) — architecture-specific SIMD operations
  on amd64 with 128/256/512-bit vector types.

### Runtime

- Goroutine leak detection: new `goroutineleak` profile detects goroutines
  blocked on unreachable concurrency primitives.

If gopls is active, call `getDiagnostics` before any manual rewrite. The
`modernize` analyzer detects patterns eligible for migration automatically
and suggests rewrites. Prefer its suggestions over hand-editing.

## Go 1.25 (August 2025)

- `testing/synctest` — synchronized concurrent testing
- `container/heap` generic
- `GOMAXPROCS` container-aware by default

## Go 1.24 (February 2025)

- `tool` directives in `go.mod` — replaces the `tools.go` pattern
- Full generic type aliases
- Swiss Tables maps (up to 60% faster)
- FIPS 140-3 native (`crypto/internal/fips140`)

## Go 1.23

- `iter` package — iterators with range-over-func
- `slices.All`, `maps.All`, `slices.Collect`
- Yield convention: a push iterator has signature `func(yield func(V) bool)`.
  `yield` returns `false` when the caller stops iteration. Never call `yield`
  after it returned `false`.

## Go 1.22

- `range N` for numeric loops
- Per-iteration loop variables (silent breaking change):

  Before 1.22 — `v` is shared across iterations, goroutines capture the
  final value:

  ```go
  for _, v := range items {
      go func() { fmt.Println(v) }() // BUG: all print last item
  }
  ```

  From 1.22 — each iteration gets its own `v`, goroutines capture correctly:

  ```go
  for _, v := range items {
      go func() { fmt.Println(v) }() // OK: each prints its own item
  }
  ```

  When reviewing code targeting < 1.22: audit every `range` loop that
  launches a goroutine and captures the iterator variable. Add explicit
  `v := v` shadowing or pass `v` as a goroutine argument.

## Go 1.21

- `min()`, `max()`, `clear()` builtins
- `slices`, `maps`, `cmp` packages
- `log/slog` structured logging
