# Troubleshooting Guide - Claude Hub Marketplace

## Issue: Only 2 Plugins Showing in Marketplace

If you're only seeing 2 out of 7 plugins when browsing the Claude Hub marketplace, try these troubleshooting steps:

### 1. Clear Claude Code Cache

Claude Code may be caching an old version of the marketplace configuration.

```bash
# Method 1: Restart Claude Code
# Close Claude Code completely and restart it

# Method 2: Clear plugin cache (if available)
# Check Claude Code settings for cache clearing options
```

### 2. Verify Marketplace Configuration

Ensure your Claude Code settings are pointing to the correct marketplace location:

```bash
# Check that Claude Code is configured to use this marketplace
# The marketplace URL should point to this repository's .claude-plugin/marketplace.json
```

**Expected marketplace configuration:**

- Repository URL: Your Claude Hub repository URL
- Marketplace file: `.claude-plugin/marketplace.json`

### 3. Verify Marketplace File

Check that the marketplace.json file is complete:

```bash
# Run the verification script
./scripts/verify-marketplace.sh

# Should show all 7 plugins:
# - rails-workflow
# - react-typescript-workflow
# - rails-code-review-agent
# - react-typescript-code-review-agent
# - ui-ux-design-agent
# - rails-dev-workflow
# - rails-mcp-servers
```

### 4. Check Plugin Metadata

All plugins now have complete metadata including:

- `author`: Plugin author information
- `homepage`: Link to plugin documentation
- `repository`: Source repository URL
- `license`: MIT license
- `category`: Plugin category (workflow, code-review, design, tools)
- `keywords`: Search keywords

You can verify this with:

```bash
python3 << 'EOF'
import json
with open('.claude-plugin/marketplace.json') as f:
    data = json.load(f)
    for plugin in data['plugins']:
        print(f"{plugin['name']}: category={plugin.get('category', 'MISSING')}")
EOF
```

### 5. Update to Latest Changes

If you cloned this repository before the recent updates, pull the latest changes:

```bash
git pull origin main
```

**Recent fixes:**

- Added complete metadata to all plugin entries in marketplace.json
- Added `author`, `homepage`, `repository`, `license` fields
- Added `category` field for better organization
- Updated verification script to handle namespace structure

### 6. Check Claude Code Version

Ensure you're using a recent version of Claude Code that supports:

- Plugin marketplaces
- Namespace structures (`./plugins/namespace/plugin-name`)
- MCP server plugins
- Full metadata fields

### 7. Manual Plugin Installation

If the marketplace is still not showing all plugins, you can install them manually:

```bash
# In your project directory
cd your-project

# Install a specific plugin manually
cp -r /path/to/claude-hub/plugins/claude-hub/rails-workflow .claude/
```

## Common Issues

### Issue: "Plugin not found" error

**Cause:** The source path in marketplace.json doesn't match the actual plugin location.

**Solution:** The source paths should be:

```json
"source": "./plugins/claude-hub/plugin-name"
```

### Issue: Plugins appear but can't be installed

**Cause:** Missing plugin.json manifest or invalid JSON.

**Solution:**

```bash
# Validate all plugin.json files
for plugin in plugins/claude-hub/*/; do
  echo "Checking $(basename $plugin)..."
  python3 -c "import json; json.load(open('$plugin/.claude-plugin/plugin.json'))" && echo "  ✓ Valid"
done
```

### Issue: MCP server plugin not appearing

**Cause:** Claude Code version may not support MCP server-only plugins.

**Solution:** Ensure your Claude Code version supports MCP server configurations in plugins.

## Verification Checklist

Before reporting an issue, verify:

- [ ] All 7 plugins are listed in `.claude-plugin/marketplace.json`
- [ ] All plugin paths exist: `./plugins/claude-hub/*/`
- [ ] All plugins have `.claude-plugin/plugin.json` manifests
- [ ] Marketplace.json is valid JSON
- [ ] Claude Code is restarted after marketplace changes
- [ ] You're using the latest version of Claude Hub
- [ ] Your Claude Code version supports marketplaces

## Getting Help

If you've tried all troubleshooting steps and still see only 2 plugins:

1. **Check which 2 plugins are visible** - This helps identify patterns
2. **Check Claude Code logs** for any error messages
3. **Verify Claude Code marketplace configuration** in settings
4. **Report the issue** with:
   - Which 2 plugins are showing
   - Your Claude Code version
   - Output of `./scripts/verify-marketplace.sh`
   - Any error messages from Claude Code

## Expected Results

After following these steps, you should see all 7 plugins:

**Workflow Plugins (3):**

1. rails-workflow (6 commands)
2. react-typescript-workflow (6 commands)
3. rails-dev-workflow (3 commands + 7 agents)

**Code Review Agents (2):**
4. rails-code-review-agent (1 agent)
5. react-typescript-code-review-agent (1 agent)

**Design Agents (1):**
6. ui-ux-design-agent (1 agent)

**Tools & Integrations (1):**
7. rails-mcp-servers (MCP servers)

## Recent Updates (Latest Session)

### What Was Fixed

1. **Added Complete Metadata** to all plugin entries:
   - author, homepage, repository, license
   - category field for organization
   - All plugins now have consistent metadata

2. **Updated Verification Script** to:
   - Handle namespace structure (`plugins/claude-hub/*/`)
   - Check MCP server configurations
   - Read plugin list from marketplace.json
   - Show correct plugin count (7)

3. **Verified All Plugins**:
   - All 7 plugins have valid plugin.json
   - All paths are correct
   - All plugins have READMEs
   - Marketplace validation passes with 0 errors, 0 warnings

### Categories Defined

- **workflow**: rails-workflow, react-typescript-workflow, rails-dev-workflow
- **code-review**: rails-code-review-agent, react-typescript-code-review-agent
- **design**: ui-ux-design-agent
- **tools**: rails-mcp-servers

---

If none of these steps resolve your issue, the problem may be with Claude Code's marketplace implementation or caching. In that case, please report the issue with detailed information about your environment and what you're seeing.
