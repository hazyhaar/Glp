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
