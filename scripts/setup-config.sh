#!/usr/bin/env bash
#
# Setup script for ccstatusline configuration
# Copies configuration files to the correct locations
#

set -e

echo "🔧 Setting up ccstatusline configuration..."

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_DIR/config"

# Create ccstatusline config directory
CCSTATUSLINE_CONFIG_DIR="$HOME/.config/ccstatusline"
mkdir -p "$CCSTATUSLINE_CONFIG_DIR"

# Copy ccstatusline settings
if [ -f "$CCSTATUSLINE_CONFIG_DIR/settings.json" ]; then
  echo "⚠️  Settings file already exists at $CCSTATUSLINE_CONFIG_DIR/settings.json"
  read -p "Overwrite? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cp "$CONFIG_DIR/settings.json" "$CCSTATUSLINE_CONFIG_DIR/settings.json"
    echo "✅ Copied settings.json to $CCSTATUSLINE_CONFIG_DIR"
  else
    echo "⏭️  Skipped settings.json"
  fi
else
  cp "$CONFIG_DIR/settings.json" "$CCSTATUSLINE_CONFIG_DIR/settings.json"
  echo "✅ Copied settings.json to $CCSTATUSLINE_CONFIG_DIR"
fi

# Detect Claude config directory
CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CLAUDE_SETTINGS="$CLAUDE_CONFIG_DIR/settings.json"

echo ""
echo "📝 Claude Code Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Add this to your Claude Code settings at:"
echo "$CLAUDE_SETTINGS"
echo ""
cat "$CONFIG_DIR/claude-settings-snippet.json"
echo ""
echo "Or run this command to add it automatically:"
echo ""
echo "  cat $CONFIG_DIR/claude-settings-snippet.json"
echo ""

echo "✨ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Build the project: bun run build"
echo "  2. Add statusLine config to $CLAUDE_SETTINGS"
echo "  3. Start a new Claude Code session to see your status line!"
