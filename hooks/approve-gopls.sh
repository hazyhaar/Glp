#!/bin/bash
# Auto-approve gopls LSP tool calls for the Glp plugin.
# Hook: PreToolUse — fires before each tool execution.
# Exit 0 + permissionDecision:"allow" = silently approved, no user prompt.

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "gopls tool auto-approved by Glp plugin"
  }
}
EOF

exit 0
