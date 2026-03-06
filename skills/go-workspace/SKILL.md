---
name: go-workspace
description: >-
  Go multi-module workspace setup and gopls configuration. Use when working
  with go.work files, multiple go.mod modules, or monorepos with internal
  replace directives.
---

## go.work — when to use

A project with `go.work` contains multiple Go modules in the same repo.
gopls loads all workspace modules and resolves cross-references.

## gopls configuration for go.work

gopls detects `go.work` automatically if present at root or in a parent
directory. If absent but needed:

```bash
go work init ./module1 ./module2 ./module3
```

## Nested modules without go.work

gopls needs a separate process per module. Claude Code starts one gopls
server per `go.mod` found. Load each module directory separately — do not
work from a parent directory without go.work.

## `tool` directives in go.mod (Go 1.24+)

```
tool golang.org/x/tools/gopls
tool github.com/golangci/golangci-lint/cmd/golangci-lint
```

`go tool gopls` launches gopls from the module without global install.
Useful for pinning gopls version per project.
