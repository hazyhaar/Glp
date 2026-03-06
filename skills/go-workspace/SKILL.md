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

## Opérations courantes

| Task | Command |
|---|---|
| Create workspace | `go work init ./m1 ./m2` |
| Add a module | `go work use ./m3` |
| Sync dependencies | `go work sync` |
| Disable workspace | `GOWORK=off go build ./...` |

`go work sync` synchronizes dependency versions across modules — the
workspace-level equivalent of `go mod tidy`.

Set `GOWORK=off` to disable the workspace for the current command. Useful
in CI or when debugging module isolation.

Never modify `go.work.sum` manually. It is managed by `go work sync`.

## gopls configuration for go.work

gopls detects `go.work` automatically if present at root or in a parent
directory. If absent but needed:

```bash
go work init ./module1 ./module2 ./module3
```

If a `go.mod` lists `replace mod => ../sibling` and that sibling module
is already in `go.work`, the workspace resolution takes precedence over
the replace directive.

**Two strategies:**

- **Remove the local replace** if the module is only built within the
  workspace (pure monorepo). This avoids ambiguity — gopls may report
  conflicting module paths otherwise.
- **Keep the local replace** if the module's CI runs outside the
  workspace (e.g., GitHub Actions checking out individual repos with
  `GOWORK=off`). In this pattern, `replace` directives are necessary
  for standalone `go build` to work, and go.work handles local dev.
  Document this choice in the module's CLAUDE.md or go.mod comments.

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
