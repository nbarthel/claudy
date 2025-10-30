#!/bin/bash

# Validate a Claude Code plugin structure
# Usage: ./scripts/validate-plugin.sh <plugin-name>

set -e

PLUGIN_NAME=$1

if [ -z "$PLUGIN_NAME" ]; then
  echo "Usage: ./scripts/validate-plugin.sh <plugin-name>"
  echo ""
  echo "Available plugins:"
  ls -1 plugins/
  exit 1
fi

PLUGIN_PATH="plugins/$PLUGIN_NAME"

if [ ! -d "$PLUGIN_PATH" ]; then
  echo "Error: Plugin '$PLUGIN_NAME' not found in plugins/"
  exit 1
fi

echo "Validating plugin: $PLUGIN_NAME"
echo "================================"
echo ""

ERRORS=0
WARNINGS=0

# Check package.json
if [ -f "$PLUGIN_PATH/package.json" ]; then
  echo "✓ package.json exists"
else
  echo "✗ package.json is missing"
  ((ERRORS++))
fi

# Check README
if [ -f "$PLUGIN_PATH/README.md" ]; then
  echo "✓ README.md exists"
else
  echo "⚠ README.md is missing (recommended)"
  ((WARNINGS++))
fi

# Check .claude-plugin directory
if [ -d "$PLUGIN_PATH/.claude-plugin" ]; then
  echo "✓ .claude-plugin directory exists"
else
  echo "✗ .claude-plugin directory is missing"
  ((ERRORS++))
  exit 1
fi

# Check plugin.json manifest
if [ -f "$PLUGIN_PATH/.claude-plugin/plugin.json" ]; then
  echo "✓ plugin.json manifest exists"

  # Validate JSON
  if command -v jq &> /dev/null; then
    if jq empty "$PLUGIN_PATH/.claude-plugin/plugin.json" 2>/dev/null; then
      echo "✓ plugin.json is valid JSON"
    else
      echo "✗ plugin.json is invalid JSON"
      ((ERRORS++))
    fi
  fi
else
  echo "✗ plugin.json manifest is missing"
  ((ERRORS++))
fi

# Check for commands or agents
HAS_COMMANDS=false
HAS_AGENTS=false

if [ -d "$PLUGIN_PATH/commands" ]; then
  COMMAND_COUNT=$(ls -1 "$PLUGIN_PATH/commands" 2>/dev/null | wc -l)
  if [ "$COMMAND_COUNT" -gt 0 ]; then
    echo "✓ Found $COMMAND_COUNT command(s)"
    HAS_COMMANDS=true
  fi
fi

if [ -d "$PLUGIN_PATH/agents" ]; then
  AGENT_COUNT=$(ls -1 "$PLUGIN_PATH/agents" 2>/dev/null | wc -l)
  if [ "$AGENT_COUNT" -gt 0 ]; then
    echo "✓ Found $AGENT_COUNT agent(s)"
    HAS_AGENTS=true
  fi
fi

if [ "$HAS_COMMANDS" = false ] && [ "$HAS_AGENTS" = false ]; then
  echo "✗ Plugin has no commands or agents"
  ((ERRORS++))
fi

# Validate markdown files
echo ""
echo "Validating markdown files:"

if [ "$HAS_COMMANDS" = true ]; then
  for file in "$PLUGIN_PATH/commands"/*.md; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      # Check if file has content
      if [ -s "$file" ]; then
        echo "  ✓ $filename has content"
      else
        echo "  ✗ $filename is empty"
        ((ERRORS++))
      fi
    fi
  done
fi

if [ "$HAS_AGENTS" = true ]; then
  for file in "$PLUGIN_PATH/agents"/*.md; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      if [ -s "$file" ]; then
        echo "  ✓ $filename has content"
      else
        echo "  ✗ $filename is empty"
        ((ERRORS++))
      fi
    fi
  done
fi

echo ""
echo "================================"
echo "Validation complete!"
echo ""
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [ "$ERRORS" -eq 0 ]; then
  echo ""
  echo "✓ Plugin is valid!"
  exit 0
else
  echo ""
  echo "✗ Plugin has errors that need to be fixed"
  exit 1
fi
