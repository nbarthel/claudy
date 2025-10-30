#!/bin/bash

# Verify Claudy marketplace is properly set up
# Usage: ./scripts/verify-marketplace.sh

echo "Claudy Marketplace Verification"
echo "=================================="
echo ""

ERRORS=0
WARNINGS=0

# Check marketplace.json
if [ -f ".claude-plugin/marketplace.json" ]; then
  echo "✓ Marketplace manifest exists"

  if command -v jq &> /dev/null; then
    if jq empty .claude-plugin/marketplace.json 2>/dev/null; then
      echo "✓ Marketplace manifest is valid JSON"

      # Check plugins list
      PLUGIN_COUNT=$(jq '.plugins | length' .claude-plugin/marketplace.json)
      echo "✓ Found $PLUGIN_COUNT plugins in marketplace"
    else
      echo "✗ Marketplace manifest is invalid JSON"
      ((ERRORS++))
    fi
  fi
else
  echo "✗ Marketplace manifest not found"
  ((ERRORS++))
fi

echo ""
echo "Validating Plugins:"
echo "-------------------"

# Check plugins from marketplace.json if available, otherwise check directory structure
if command -v jq &> /dev/null && [ -f ".claude-plugin/marketplace.json" ]; then
  # Get plugin paths from marketplace.json
  plugin_count=0
  while IFS= read -r plugin_source; do
    plugin_dir="${plugin_source#./}"  # Remove ./ prefix
    plugin_name=$(basename "$plugin_dir")
    ((plugin_count++))

    echo ""
    echo "Checking $plugin_name..."

    # Check plugin.json
    if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
      echo "  ✓ plugin.json exists"
    else
      echo "  ✗ plugin.json missing"
      ((ERRORS++))
    fi

    # Check for content
    has_content=false
    if [ -d "$plugin_dir/commands" ] && [ "$(ls -A $plugin_dir/commands 2>/dev/null)" ]; then
      cmd_count=$(ls -1 "$plugin_dir/commands" | wc -l)
      echo "  ✓ $cmd_count command(s)"
      has_content=true
    fi

    if [ -d "$plugin_dir/agents" ] && [ "$(ls -A $plugin_dir/agents 2>/dev/null)" ]; then
      agent_count=$(ls -1 "$plugin_dir/agents" | wc -l)
      echo "  ✓ $agent_count agent(s)"
      has_content=true
    fi

    # Check for MCP servers
    if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
      if grep -q '"mcp"' "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null; then
        echo "  ✓ MCP server configuration"
        has_content=true
      fi
    fi

    if [ "$has_content" = false ]; then
      echo "  ⚠ No commands, agents, or MCP servers found"
      ((WARNINGS++))
    fi

    # Check README
    if [ -f "$plugin_dir/README.md" ]; then
      echo "  ✓ README.md exists"
    else
      echo "  ⚠ README.md missing"
      ((WARNINGS++))
    fi
  done < <(jq -r '.plugins[].source' .claude-plugin/marketplace.json)
else
  # Fallback to checking plugins directory (supports both flat and namespace structures)
  for plugin_dir in plugins/*/ plugins/*/*/; do
    [ -d "$plugin_dir" ] || continue
    [ -f "$plugin_dir/.claude-plugin/plugin.json" ] || continue

    plugin_name=$(basename "$plugin_dir")
    echo ""
    echo "Checking $plugin_name..."

    echo "  ✓ plugin.json exists"

    # Check for content
    has_content=false
    if [ -d "$plugin_dir/commands" ] && [ "$(ls -A $plugin_dir/commands 2>/dev/null)" ]; then
      cmd_count=$(ls -1 "$plugin_dir/commands" | wc -l)
      echo "  ✓ $cmd_count command(s)"
      has_content=true
    fi

    if [ -d "$plugin_dir/agents" ] && [ "$(ls -A $plugin_dir/agents 2>/dev/null)" ]; then
      agent_count=$(ls -1 "$plugin_dir/agents" | wc -l)
      echo "  ✓ $agent_count agent(s)"
      has_content=true
    fi

    # Check for MCP servers
    if grep -q '"mcp"' "$plugin_dir/.claude-plugin/plugin.json" 2>/dev/null; then
      echo "  ✓ MCP server configuration"
      has_content=true
    fi

    if [ "$has_content" = false ]; then
      echo "  ⚠ No commands, agents, or MCP servers found"
      ((WARNINGS++))
    fi

    # Check README
    if [ -f "$plugin_dir/README.md" ]; then
      echo "  ✓ README.md exists"
    else
      echo "  ⚠ README.md missing"
      ((WARNINGS++))
    fi
  done
fi

echo ""
echo "=================================="
echo "Verification Complete!"
echo ""
echo "Summary:"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
if command -v jq &> /dev/null && [ -f ".claude-plugin/marketplace.json" ]; then
  echo "  Total Plugins: $(jq '.plugins | length' .claude-plugin/marketplace.json)"
else
  echo "  Total Plugins: $(find plugins -name "plugin.json" -path "*/.claude-plugin/plugin.json" | wc -l)"
fi

if [ $ERRORS -eq 0 ]; then
  echo ""
  echo "✓ Marketplace is ready to use!"
  echo ""
  echo "To use the marketplace:"
  echo "  1. Configure Claude Code to use this marketplace"
  echo "  2. Run: /plugin"
  echo "  3. Browse and install plugins"
  exit 0
else
  echo ""
  echo "✗ Please fix errors before using the marketplace"
  exit 1
fi
