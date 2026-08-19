#!/bin/bash
# SessionStart hook -- installs the Banana Claude skill and (if an API key is
# available) configures the nanobanana-mcp server for this session.
#
# Only runs in Claude Code on the web (remote) sessions. Local sessions
# should install manually via install.sh so they can choose their own key.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILL_NAME="banana"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"
SOURCE_DIR="$CLAUDE_PROJECT_DIR/skills/$SKILL_NAME"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 0
fi

mkdir -p "$SKILL_DIR"
cp -r "$SOURCE_DIR"/* "$SKILL_DIR/"
chmod +x "$SKILL_DIR/scripts/"*.py 2>/dev/null || true
mkdir -p "$HOME/.banana/presets"
echo "Banana Claude skill installed to $SKILL_DIR"

if [ -n "${GOOGLE_AI_API_KEY:-}" ]; then
  python3 "$SKILL_DIR/scripts/setup_mcp.py" --key "$GOOGLE_AI_API_KEY"
else
  echo "GOOGLE_AI_API_KEY is not set in this environment -- skipping MCP server configuration." >&2
  echo "Add GOOGLE_AI_API_KEY as an environment variable in this environment's settings to enable image generation." >&2
fi

python3 "$SKILL_DIR/scripts/validate_setup.py" || true
