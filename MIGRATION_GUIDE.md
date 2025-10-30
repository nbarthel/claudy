# Migration Guide - Plugin Naming Updates

**Date:** October 17, 2025
**Version:** 0.2.0

## Overview

We've renamed all plugins and agents to follow consistent naming best practices. This improves discoverability, clarity, and follows CLI naming conventions.

## What Changed

### Plugin Names

| Old Name | New Name | Reason |
|----------|----------|--------|
| `rails-workflow` | `rails-generators` | Clearer purpose - focuses on generation commands |
| `rails-dev-workflow` | `rails-api-workflow` | Focuses on API development, Rails 8 optimized |
| `rails-code-review-agent` | `rails-code-reviewer` | Shorter, agent suffix redundant |
| `react-typescript-code-review-agent` | `react-typescript-reviewer` | Shorter, agent suffix redundant |
| `ui-ux-design-agent` | `ui-ux-designer` | Shorter, agent suffix redundant |

### Agent Files (in rails-api-workflow)

| Old Name | New Name | Reason |
|----------|----------|--------|
| `rails-models.md` | `rails-model-specialist.md` | Singular, role-based naming |
| `rails-controllers.md` | `rails-controller-specialist.md` | Singular, role-based naming |
| `rails-views.md` | `rails-view-specialist.md` | Singular, role-based naming |
| `rails-services.md` | `rails-service-specialist.md` | Singular, role-based naming |
| `rails-tests.md` | `rails-test-specialist.md` | Singular, role-based naming |

### Command Files (in rails-api-workflow)

| Old Name | New Name | Reason |
|----------|----------|--------|
| `rails-dev.md` | `rails-start-dev.md` | Verb consistency (start) |
| `rails-feature.md` | `rails-add-feature.md` | Verb consistency (add) |

## How to Migrate

### If You've Installed Plugins

**Option 1: Uninstall and Reinstall (Recommended)**

```bash
# In your project with Claude Code

# Uninstall old plugins
/plugin uninstall rails-workflow@claude-hub
/plugin uninstall rails-dev-workflow@claude-hub
/plugin uninstall rails-code-review-agent@claude-hub
/plugin uninstall react-typescript-code-review-agent@claude-hub
/plugin uninstall ui-ux-design-agent@claude-hub

# Install new plugins
/plugin install rails-generators@claude-hub
/plugin install rails-api-workflow@claude-hub
/plugin install rails-code-reviewer@claude-hub
/plugin install react-typescript-reviewer@claude-hub
/plugin install ui-ux-designer@claude-hub
```

**Option 2: Manual Directory Rename**

If you've manually copied plugins to your project:

```bash
# In your project's .claude directory
cd .claude

# Rename plugin directories
mv rails-workflow rails-generators 2>/dev/null || true
mv rails-dev-workflow rails-api-workflow 2>/dev/null || true
mv rails-code-review-agent rails-code-reviewer 2>/dev/null || true
mv react-typescript-code-review-agent react-typescript-reviewer 2>/dev/null || true
mv ui-ux-design-agent ui-ux-designer 2>/dev/null || true

# Update agent files in rails-api-workflow
cd rails-api-workflow/agents 2>/dev/null || true
mv rails-models.md rails-model-specialist.md 2>/dev/null || true
mv rails-controllers.md rails-controller-specialist.md 2>/dev/null || true
mv rails-views.md rails-view-specialist.md 2>/dev/null || true
mv rails-services.md rails-service-specialist.md 2>/dev/null || true
mv rails-tests.md rails-test-specialist.md 2>/dev/null || true

# Update command files
cd ../commands 2>/dev/null || true
mv rails-dev.md rails-start-dev.md 2>/dev/null || true
mv rails-feature.md rails-add-feature.md 2>/dev/null || true
```

### If You're Updating Claude Hub Repository

```bash
# Pull latest changes
git pull origin main

# The renames are already done in the repository
# Just verify the marketplace
./scripts/verify-marketplace.sh
```

## Command Reference Updates

### Rails Generators (formerly rails-workflow)

Commands remain the same:

- `/rails-generate-model`
- `/rails-generate-controller`
- `/rails-add-turbo-stream`
- `/rails-add-service-object`
- `/rails-setup-rspec`
- `/rails-add-api-endpoint`

### Rails Advanced Workflow (formerly rails-dev-workflow)

**Updated Commands:**

- `/rails-dev` → `/rails-start-dev`
- `/rails-feature` → `/rails-add-feature`
- `/rails-refactor` (unchanged)

**Updated Agents:**

- `rails-models` → `rails-model-specialist`
- `rails-controllers` → `rails-controller-specialist`
- `rails-views` → `rails-view-specialist`
- `rails-services` → `rails-service-specialist`
- `rails-tests` → `rails-test-specialist`
- `rails-architect` (unchanged)
- `rails-devops` (unchanged)

### React TypeScript Workflow

Commands unchanged:

- `/react-create-component`
- `/react-create-hook`
- `/react-setup-context`
- `/react-setup-testing`
- `/react-add-form-handling`
- `/react-add-data-fetching`

### Code Reviewers

Agent names updated but usage remains the same:

- `rails-code-review-agent` → `rails-code-reviewer`
- `react-typescript-code-review-agent` → `react-typescript-reviewer`

### UI/UX Designer

Agent name updated:

- `ui-ux-design-agent` → `ui-ux-designer`

## Breaking Changes

### None for End Users

✅ **All slash commands remain the same** - No need to update your workflows
✅ **Plugin functionality unchanged** - Same features and capabilities
✅ **Backward compatibility** - Old installations continue to work

### For Plugin Developers

⚠️ If you've forked or extended these plugins:

- Update your marketplace.json references
- Update documentation
- Rename plugin directories to match new names
- Update any hardcoded plugin name references

## Naming Conventions Going Forward

### Plugins

**Format:** `{framework|domain}-{purpose}[-{type}]`

- ✅ rails-generators
- ✅ rails-api-workflow
- ✅ react-typescript-reviewer

### Commands

**Format:** `{framework}-{verb}-{noun}`

- Verbs: generate, create, add, setup, start, configure
- ✅ rails-generate-model
- ✅ rails-start-dev
- ✅ react-create-component

### Agents

**Format:** `{framework|domain}-{role|specialty}`

- Roles: reviewer, designer, architect, specialist, expert
- Use singular nouns
- ✅ rails-reviewer
- ✅ rails-model-specialist
- ✅ ui-ux-designer

## Benefits of This Change

1. **Clearer Purpose** - `rails-generators` vs `rails-workflow` immediately tells you what it does
2. **Easier Discovery** - Shorter names are easier to type and remember
3. **Consistency** - All names follow the same pattern
4. **Better Organization** - Clear distinction between basic and advanced workflows
5. **Future-Proof** - Established conventions for new plugins

## Verification

After migrating, verify your plugins:

```bash
# List installed plugins
/plugin list

# Should show new names:
# - rails-generators@claude-hub
# - rails-api-workflow@claude-hub
# - rails-code-reviewer@claude-hub
# - react-typescript-reviewer@claude-hub
# - ui-ux-designer@claude-hub
```

## Troubleshooting

### "Plugin not found" error

If you get a "plugin not found" error:

1. Update your Claude Hub repository: `git pull origin main`
2. Clear Claude Code cache (restart Claude Code)
3. Reinstall the plugin with the new name

### Old commands still showing

If old commands are still available:

1. Uninstall the old plugin completely
2. Restart Claude Code
3. Install the new plugin

### Agent not found

If an agent isn't found in rails-api-workflow:

1. Reinstall the plugin
2. Check you're using the new agent names (e.g., `rails-model-specialist` not `rails-models`)

## Support

If you encounter issues:

1. Check this migration guide
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Report issues at <https://github.com/claude-squad/claude-hub/issues>

## Timeline

- **October 17, 2025** - Naming updates released
- **Backward Compatibility** - Old installations continue to work
- **Recommended Migration** - Update at your convenience

---

**Questions?** See [README.md](README.md) for updated plugin documentation.
