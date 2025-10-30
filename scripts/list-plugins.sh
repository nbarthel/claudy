#!/bin/bash

# List all available Claude Code plugins with their descriptions
# Usage: ./scripts/list-plugins.sh

echo "Available Claude Code Plugins"
echo "============================="
echo ""

for plugin_dir in plugins/*/; do
  plugin_name=$(basename "$plugin_dir")

  # Get description from package.json if available
  if [ -f "$plugin_dir/package.json" ]; then
    description=$(grep -o '"description": *"[^"]*"' "$plugin_dir/package.json" | cut -d'"' -f4)
  else
    description="No description available"
  fi

  # Count commands and agents
  commands=0
  agents=0

  if [ -d "$plugin_dir/commands" ]; then
    commands=$(ls -1 "$plugin_dir/commands" 2>/dev/null | wc -l)
  fi

  if [ -d "$plugin_dir/agents" ]; then
    agents=$(ls -1 "$plugin_dir/agents" 2>/dev/null | wc -l)
  fi

  echo "Plugin: $plugin_name"
  echo "  Description: $description"
  echo "  Commands: $commands"
  echo "  Agents: $agents"
  echo ""
done

echo "To show plugin info:"
echo "  ./scripts/install-plugin.sh <plugin-name>"
echo ""
echo "To validate a plugin:"
echo "  ./scripts/validate-plugin.sh <plugin-name>"
echo ""
echo "To install via Claude Code:"
echo "  /plugin install <plugin-name>@claude-hub"
