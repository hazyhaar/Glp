> **Protocole** — Ce plugin est hors monorepo HOROS. Pas de dépendance au protocole de recherche `/devhoros/CLAUDE.md`.
> Son CLAUDE.md est autonome.

# CLAUDE.md — Glp (gopls-lsp plugin)

Plugin Claude Code intégrant gopls (Go Language Server) via MCP.

## Responsabilité

Fournir l'intelligence sémantique Go (navigation, diagnostics, refactoring) aux agents Claude Code via 6 outils MCP gopls.

## Architecture

```
Glp/
├── .claude-plugin/plugin.json   # Manifeste plugin (name, version, entry points)
├── .mcp.json                    # ACTIF — gopls en mode MCP stdio (`gopls mcp`)
├── .lsp.json                    # INACTIF — fallback canal lspServers (buggé upstream)
├── skills/
│   ├── go-lsp/SKILL.md          # Guide outils MCP gopls
│   ├── go-modern/SKILL.md       # Idiomes Go 1.21-1.26
│   ├── go-workspace/SKILL.md    # Multi-module go.work
│   ├── go-mod/SKILL.md          # Gestion go.mod
│   └── marketplace-check/SKILL.md  # Audit compliance marketplace
├── agents/
│   └── go-reviewer.md           # Code reviewer gopls + staticcheck
├── README.md
└── LICENSE
```

## Canal actif : MCP (pas LSP)

Le canal `lspServers` de Claude Code est buggé (issues #14803, #16214, #20050).
gopls v0.20.0 expose un mode MCP natif (`gopls mcp`) en stdio.

- **`.mcp.json`** : `{"gopls": {"command": "go", "args": ["run", "golang.org/x/tools/gopls@latest", "mcp"]}}` — actif
- **`.lsp.json`** : config LSP classique avec staticcheck, analyzers, hints — inactif, conservé comme fallback

## Outils MCP exposés

| Outil | Rôle | Quand l'utiliser |
|-------|------|------------------|
| `go_workspace` | Structure workspace (modules, go.work) | Premier appel sur tout projet Go |
| `go_search` | Recherche fuzzy de symboles cross-module | Symbole introuvable par Grep |
| `go_file_context` | Dépendances intra-package d'un fichier | Après premier Read d'un fichier Go |
| `go_package_api` | API publique d'un package | Comprendre un package sans le lire |
| `go_symbol_references` | Toutes les références à un symbole | Avant toute modification d'un symbole public |
| `go_diagnostics` | Erreurs build/parse temps réel | Après tout edit Go, avant les tests |

## Prérequis

- Go 1.24+ dans le PATH (1.26 pour toutes les features)
- `gopls` n'a pas besoin d'être installé — lancé via `go run golang.org/x/tools/gopls@latest`

## Intégration HOROS

Le protocole de recherche HOROS (`/devhoros/CLAUDE.md`) référence ces outils en section "Compléments LSP gopls". Le LSP **complète** le protocole existant (Grep CLAUDE:SUMMARY/WARN), il ne le remplace pas.

## Invariants

- **Ne jamais supprimer `.lsp.json`** — fallback pour quand Anthropic fixera le canal LSP
- **`.mcp.json` doit rester minimal** — gopls gère sa config via `go.work` et ses defaults
- **`@latest` = toujours dernière version gopls** — pas de pin de version, le cache Go module gère la résolution
- **Les skills sont la doc utilisateur** — le SKILL.md de `go-lsp` est le guide de référence pour les agents
- **Pas de code Go dans ce repo** — c'est un plugin de configuration, pas une bibliothèque

## Pièges connus

- gopls MCP ne supporte pas encore `textDocument/hover` ni `textDocument/definition` — seulement les 6 outils listés ci-dessus
- Sur un workspace avec 13+ modules (comme HOROS), le premier `go_workspace` peut prendre 5-10s à cause de l'indexation
- `go_diagnostics` sans paramètre `files` scanne tout le workspace — toujours passer les fichiers touchés
