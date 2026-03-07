# gopls-lsp — Claude Code Plugin

Integrates [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) (the official Go language server) into Claude Code via MCP. Provides semantic code intelligence for Go projects: search, diagnostics, references, file context, and package API inspection.

## What this plugin provides

| Component | Purpose |
|---|---|
| **MCP server** (`.mcp.json`) | gopls in MCP stdio mode (`gopls mcp`) — active channel |
| **LSP config** (`.lsp.json`) | gopls LSP fallback — inactive, kept for when Claude Code fixes LSP channel |
| **Skill: go-lsp** | When and how to use the 6 MCP tools |
| **Skill: go-modern** | Go 1.21→1.26 idioms guide, auto-detects version from `go.mod` |
| **Skill: go-workspace** | Multi-module `go.work` setup and gopls configuration |
| **Skill: go-mod** | Managing go.mod: deps, tool directives, troubleshooting |
| **Skill: goreview** | Comprehensive Go code review (gopls + linters + patterns) |
| **Skill: marketplace-check** | Audit plugin repos for marketplace compliance |
| **Agent: go-reviewer** | Code reviewer using MCP diagnostics + staticcheck |

## How it works

gopls v0.20.0+ exposes a native MCP mode (`gopls mcp`) over stdio. This plugin uses that mode — not the LSP channel, which has [known bugs](https://github.com/anthropics/claude-code/issues/14803) in Claude Code.

The 6 MCP tools exposed by gopls:

| Tool | Purpose |
|------|---------|
| `go_workspace` | Workspace structure (modules, go.work) |
| `go_search` | Fuzzy symbol search across modules |
| `go_file_context` | Intra-package dependencies of a file |
| `go_package_api` | Public API of a package |
| `go_symbol_references` | All references to a symbol |
| `go_diagnostics` | Build/parse errors in real time |

## Prerequisites

- **Go** 1.24+ in PATH (1.26 recommended for all features)

No separate `gopls` install needed — launched via `go run golang.org/x/tools/gopls@latest mcp`.

## Installation

```
/plugin marketplace add hazyhaar/gopls-lsp
/plugin install gopls-lsp
```

Restart Claude Code. gopls starts automatically when a Go workspace is detected.

## Multi-module setup

For a monorepo with multiple `go.mod`, create a `go.work` at root:

```bash
go work init ./module1 ./module2
```

gopls loads the entire workspace as a single instance.

## Plugin structure

```
gopls-lsp/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── .mcp.json                    # ACTIVE — gopls MCP stdio config
├── .lsp.json                    # INACTIVE — LSP fallback (upstream bugs)
├── CLAUDE.md                    # Plugin internals and invariants
├── skills/
│   ├── go-lsp/SKILL.md          # MCP tools usage guide
│   ├── go-modern/SKILL.md       # Modern Go idioms (1.21→1.26)
│   ├── go-workspace/SKILL.md    # Multi-module workspace
│   ├── go-mod/SKILL.md          # go.mod management
│   ├── goreview/SKILL.md        # Full code review workflow
│   └── marketplace-check/SKILL.md  # Marketplace compliance audit
├── agents/
│   └── go-reviewer.md           # Go code review agent
├── LICENSE
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).
