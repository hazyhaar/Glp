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

- `new(expr)` — creates an initialized pointer: `p := new(42)` instead of
  `x := 42; p := &x`
- `errors.AsType[T](err)` — replaces `errors.As` with typed return,
  avoids pointer setup and type panics
- Self-referential generics: `type Adder[A Adder[A]] interface{...}`
- GC Green Tea enabled by default (was experimental in 1.25)
- `crypto/hpke` — post-quantum HPKE (RFC 9180)

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

## Go 1.22

- `range N` for numeric loops
- Per-iteration loop variables (silent breaking change)

## Go 1.21

- `min()`, `max()`, `clear()` builtins
- `slices`, `maps`, `cmp` packages
- `log/slog` structured logging
