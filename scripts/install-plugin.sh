#!/bin/bash

# Install a Claude Code plugin using the official plugin installer format
# Usage: ./scripts/install-plugin.sh <plugin-name>

set -e

PLUGIN_NAME=$1

if [ -z "$PLUGIN_NAME" ]; then
  echo "Usage: ./scripts/install-plugin.sh <plugin-name>"
  echo ""
  echo "Available plugins:"
  ls -1 plugins/
  echo ""
  echo "Installation methods:"
  echo "  1. Interactive: /plugin"
  echo "  2. Direct: /plugin install $PLUGIN_NAME@claudy"
  exit 1
fi

PLUGIN_PATH="plugins/$PLUGIN_NAME"

if [ ! -d "$PLUGIN_PATH" ]; then
  echo "Error: Plugin '$PLUGIN_NAME' not found in plugins/"
  echo ""
  echo "Available plugins:"
  ls -1 plugins/
  exit 1
fi

# Check if plugin has correct structure
if [ ! -d "$PLUGIN_PATH/.claude-plugin" ]; then
  echo "Error: Plugin '$PLUGIN_NAME' does not have a .claude-plugin directory"
  exit 1
fi

if [ ! -f "$PLUGIN_PATH/.claude-plugin/plugin.json" ]; then
  echo "Error: Plugin '$PLUGIN_NAME' does not have a plugin.json manifest"
  exit 1
fi

echo "Plugin: $PLUGIN_NAME"
echo "Location: $PLUGIN_PATH"
echo ""

# Show plugin info
echo "Plugin Information:"
cat "$PLUGIN_PATH/.claude-plugin/plugin.json" | grep -E '(name|description|version)' | sed 's/^/  /'
echo ""

# Show what's included
if [ -d "$PLUGIN_PATH/commands" ]; then
  COMMAND_COUNT=$(ls -1 "$PLUGIN_PATH/commands" 2>/dev/null | wc -l)
  echo "Commands: $COMMAND_COUNT"
  ls -1 "$PLUGIN_PATH/commands" 2>/dev/null | sed 's/\.md$//' | sed 's/^/  - /'
fi

if [ -d "$PLUGIN_PATH/agents" ]; then
  AGENT_COUNT=$(ls -1 "$PLUGIN_PATH/agents" 2>/dev/null | wc -l)
  echo ""
  echo "Agents: $AGENT_COUNT"
  ls -1 "$PLUGIN_PATH/agents" 2>/dev/null | sed 's/\.md$//' | sed 's/^/  - /'
fi

echo ""
echo "To install this plugin:"
echo "  1. In Claude Code, run: /plugin"
echo "  2. Or run: /plugin install $PLUGIN_NAME@claudy"
echo ""
echo "The Claudy marketplace needs to be configured in Claude Code first."
echo "See README.md for marketplace setup instructions."
