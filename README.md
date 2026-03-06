# gopls-lsp — Claude Code Plugin

Integrates [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) (the official Go language server) into Claude Code. Provides semantic code intelligence for Go projects: jump-to-definition, find-references, real-time diagnostics, hover documentation, and staticcheck analysis.

## What this plugin provides

| Component | Purpose |
|---|---|
| **LSP server** (`.lsp.json`) | gopls with staticcheck, modernize analyzer, full hints |
| **Skill: go-lsp** | When to use LSP vs grep for code navigation |
| **Skill: go-modern** | Go 1.21→1.26 idioms guide, auto-detects version from `go.mod` |
| **Skill: go-workspace** | Multi-module `go.work` setup and gopls configuration |
| **Skill: go-mod** | Managing go.mod: deps, tool directives, troubleshooting |
| **Skill: marketplace-check** | Audit plugin repos for marketplace compliance |
| **Agent: go-reviewer** | Code reviewer using LSP diagnostics + staticcheck |

## Prerequisites

- **Go** 1.24+ recommended (1.26 for all features)
- **gopls** installed and in PATH:

```bash
# Global install
go install golang.org/x/tools/gopls@latest

# Or via tool directive in go.mod (Go 1.24+)
go get -tool golang.org/x/tools/gopls@latest
```

Verify: `gopls version` should return v0.18.0+

## Installation

```
/plugin marketplace add hazyhaar/gopls-lsp
/plugin install gopls-lsp
```

Restart Claude Code. gopls starts automatically when opening a `.go` file.

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
│   └── plugin.json           # Plugin manifest
├── .lsp.json                 # gopls LSP configuration
├── skills/
│   ├── go-lsp/SKILL.md       # LSP usage guidance
│   ├── go-modern/SKILL.md    # Modern Go idioms
│   ├── go-workspace/SKILL.md # Multi-module workspace
│   ├── go-mod/SKILL.md       # go.mod management
│   └── marketplace-check/SKILL.md  # Marketplace compliance audit
├── agents/
│   └── go-reviewer.md        # Go code review agent
├── LICENSE
└── README.md
```

## License

MIT — see [LICENSE](LICENSE).
