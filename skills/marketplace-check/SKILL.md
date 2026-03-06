---
name: marketplace-check
description: >-
  Audit a repo and check if it is compliant with the Claude Code official
  marketplace requirements. Use when preparing a plugin for submission to
  anthropics/claude-plugins-official.
---

## What to check

When asked to audit a plugin for marketplace compliance, verify:

### Structure
- `.claude-plugin/plugin.json` exists at repo root
- `README.md` exists at repo root
- `LICENSE` exists at repo root
- Component dirs (`skills/`, `agents/`, `hooks/`, `commands/`) are at root,
  NOT inside `.claude-plugin/`

### Manifest (plugin.json)
- `name`: present, kebab-case
- `version`: present, valid semver (e.g. `1.0.0`)
- `description`: present, non-empty
- `author`: present with `name` field
- `license`: present, valid SPDX identifier (e.g. `MIT`, `Apache-2.0`)
- `keywords`: present, array with at least one entry

### Components
- Skills: each `SKILL.md` has valid YAML frontmatter with `name` and
  `description` fields
- Agents: each `.md` has valid YAML frontmatter with `name`, `description`,
  and `model` fields
- Hooks: valid event names (`UserPromptSubmit`, `PreToolUse`, `PostToolUse`,
  `SessionStart`, `SessionEnd`, `Stop`, `PreCompact`)
- MCP: valid JSON in `.mcp.json`
- LSP: valid JSON in `.lsp.json`

### LSP validation (.lsp.json)
For each language server entry in `.lsp.json`:
- **ERROR** `command` is present and non-empty
- **ERROR** `extensionToLanguage` is present, is an object, and contains at
  least one mapping (e.g. `{".go": "go"}`)
- **ERROR** `transport`, when present, is one of `"stdio"` or `"tcp"`.
  If the field is absent, that is acceptable (defaults to `"stdio"`)

### Manifest ↔ disk coherence
For every component path declared in `plugin.json` (`skills`, `agents`,
`hooks`, `mcpServers`, `lspServers`):
- **FATAL** the target file or directory must exist on disk relative to the
  plugin root. A missing target means the plugin will fail to load at runtime

When `skills` points to a directory, every immediate subdirectory must
contain a `SKILL.md`. When `agents` points to a directory, it must contain
at least one `.md` file.

### Agent model strings
For every agent `.md` in `agents/`:
- **WARNING** the `model` frontmatter field, if present, must be one of the
  known valid values: `sonnet`, `opus`, `haiku`, `inherit`,
  `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`.
  An unrecognised value may cause silent fallback or errors at runtime

### Shell script hygiene
For every `.sh` file under the plugin root:
- **WARNING** first line must be a shebang (`#!/usr/bin/env bash`,
  `#!/bin/bash`, `#!/bin/sh`, or similar)
- **WARNING** script should contain `set -e` or `set -euo pipefail` near the
  top (within the first 10 lines) to fail fast on errors
- **WARNING** flag obvious unquoted variable expansions (`$VAR` or
  `${VAR}` outside of double quotes in command arguments). This does NOT
  apply inside `[[ ]]` tests or arithmetic contexts

### Keywords relevance
In `plugin.json`:
- **WARNING** `keywords` must contain at least one entry that relates to the
  language, framework, or domain the plugin targets (e.g. `"go"`, `"python"`,
  `"lsp"`, `"testing"`). Generic-only keywords like `["plugin"]` or
  `["claude"]` are insufficient for marketplace discovery

### Security
- No hardcoded secrets (API keys, tokens, passwords) in any file
- Shell scripts have appropriate permissions (no world-writable)

### Documentation
- README includes installation instructions
- README includes usage examples
- README describes prerequisites

### Marketplace-specific
- Plugin declares scope (what files/languages it affects)
- Source links are valid
- External connections are disclosed if any

## Output format

Report findings as:
- **FATAL**: Blocks submission (missing required files/fields)
- **ERROR**: Must fix before submission
- **WARNING**: Recommended fix
- **PASS**: Check passed

End with a verdict: **READY TO SUBMIT** / **NEEDS FIXES** / **NOT COMPLIANT**
