---
name: go-mod
description: >-
  Guide for managing go.mod files correctly. Use when adding dependencies,
  updating module versions, managing tool directives, or troubleshooting
  dependency issues in Go projects.
---

## Reading go.mod

Always read `go.mod` before modifying dependencies. Key directives:
- `module` — the module path
- `go X.Y` — minimum Go version, gates available language features
- `require` — direct and indirect dependencies
- `replace` — local overrides (common in monorepos)
- `exclude` — blocked versions
- `tool` — project-pinned CLI tools (Go 1.24+)

## Adding dependencies

Never edit `go.mod` by hand to add a dependency. Use:

```bash
go get github.com/example/pkg@latest
```

Then run `go mod tidy` to clean up.

## Tool directives (Go 1.24+)

Replace the old `tools.go` + blank import pattern with:

```
tool golang.org/x/tools/gopls
tool github.com/golangci/golangci-lint/cmd/golangci-lint
```

Install with `go get -tool <path>@<version>`, run with `go tool <name>`.

## Common operations

| Task | Command |
|---|---|
| Add dependency | `go get pkg@version` |
| Remove unused deps | `go mod tidy` |
| Vendor dependencies | `go mod vendor` |
| Check why a dep exists | `go mod why pkg` |
| Show dependency graph | `go mod graph` |
| Upgrade all deps | `go get -u ./...` |
| Upgrade patch only | `go get -u=patch ./...` |
| Download without install | `go mod download` |

## Version queries

`go get` accepts version queries:
- `@latest` — latest tagged release
- `@v1.2.3` — exact version
- `@>=1.2.0` — minimum version
- `@master` or `@branch` — branch tip (pseudo-version)
- `@none` — remove dependency

## Troubleshooting

- **"missing go.sum entry"** → run `go mod tidy`
- **"ambiguous import"** → check for duplicate module paths, use `replace`
- **version conflict** → `go mod graph | grep pkg` to find the conflict chain
- **replace directive in library** → `replace` is ignored when the module is consumed as a dependency; only the root module's `replace` applies
