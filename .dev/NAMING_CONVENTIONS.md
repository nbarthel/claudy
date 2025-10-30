# Naming Conventions - Claude Hub

**Version:** 1.0
**Last Updated:** October 17, 2025

## Overview

This document establishes naming conventions for all plugins, commands, and agents in the Claude Hub marketplace. Following these conventions ensures consistency, discoverability, and a better user experience.

## Plugin Naming

### Format
```
{framework|domain}-{purpose}[-{type}]
```

### Rules
1. Use **kebab-case** (all lowercase with hyphens)
2. Start with **framework or domain** (rails, react, ui-ux, etc.)
3. Describe the **purpose** (generators, reviewer, designer)
4. Optionally add **type** for disambiguation (workflow, advanced, etc.)

### Examples

✅ **Good Names:**
- `rails-generators` - Clear purpose, framework prefix
- `rails-advanced-workflow` - Purpose + type for disambiguation
- `react-typescript-reviewer` - Framework + technology + role
- `ui-ux-designer` - Domain + role
- `rails-mcp-servers` - Framework + technology + type

❌ **Bad Names:**
- `my-plugin` - Not descriptive
- `rails` - Too generic
- `RailsWorkflow` - Wrong case (should be kebab-case)
- `rails_generators` - Wrong separator (use hyphens not underscores)
- `rails-code-review-agent` - Redundant suffix (category already indicates it's an agent)

### Avoiding Redundancy

When the category already conveys information, don't repeat it in the name:

- ❌ `rails-code-review-agent` (category: code-review)
- ✅ `rails-code-reviewer` (category: code-review)

The `-agent` suffix is redundant because the category already tells users it's an agent.

## Command Naming

### Format
```
{framework}-{verb}-{noun}
```

### Rules
1. Use **kebab-case**
2. Start with **framework prefix** for discoverability
3. Use consistent **action verbs**
4. End with the **target noun**

### Approved Verbs

Use these verbs consistently:
- `generate` - Create new code from templates
- `create` - Make new components/files
- `add` - Add features to existing code
- `setup` - Initial configuration
- `configure` - Modify configuration
- `start` - Begin a process
- `build` - Compile or construct
- `test` - Run tests
- `deploy` - Deployment operations

### Examples

✅ **Good Commands:**
- `/rails-generate-model` - framework-verb-noun
- `/rails-add-turbo-stream` - Clear action and target
- `/react-create-component` - Standard verb
- `/rails-setup-rspec` - Configuration command
- `/rails-start-dev` - Process initiation

❌ **Bad Commands:**
- `/rails-model` - Missing verb
- `/generate-model` - Missing framework prefix
- `/rails-make-model` - Non-standard verb (use `generate` or `create`)
- `/rails-dev` - Unclear (start? stop? configure?)
- `/model` - Not discoverable, too generic

### Command Discoverability

Framework prefixes make commands discoverable:
```bash
# User can type /rails and see all Rails commands
/rails-generate-model
/rails-add-turbo-stream
/rails-setup-rspec

# Or /react for React commands
/react-create-component
/react-create-hook
```

## Agent Naming

### Format
```
{framework|domain}-{role|specialty}
```

### Rules
1. Use **kebab-case**
2. Start with **framework or domain**
3. Use **singular nouns** for roles
4. Be specific about the specialty

### Approved Roles

Use these role names:
- `reviewer` - Code review specialist
- `designer` - UI/UX design specialist
- `architect` - System architecture expert
- `specialist` - Focused on specific component
- `expert` - General expertise
- `builder` - Construction/creation focus
- `optimizer` - Performance focus

### Examples

✅ **Good Agent Names:**
- `rails-reviewer` - Singular, clear role
- `rails-model-specialist` - Specific specialty
- `ui-ux-designer` - Domain + role
- `rails-architect` - High-level design role
- `react-typescript-reviewer` - Framework + tech + role

❌ **Bad Agent Names:**
- `rails-models` - Plural (use singular)
- `rails-review-agent` - Redundant suffix
- `model-agent` - Missing framework prefix
- `rails-stuff` - Not descriptive
- `rails-code-review-agent` - Too long, redundant

### Singular vs Plural

Always use singular for agents:

- ❌ `rails-models` - Plural
- ✅ `rails-model-specialist` - Singular

**Rationale:** You're invoking a single agent, and singular is clearer: "use the rails-model-specialist agent" vs "use the rails-models agent"

## Namespace Naming

### Format
```
{organization|project}
```

### Rules
1. Use **kebab-case**
2. Keep it short and memorable
3. Represents the organization or project

### Examples

✅ **Good Namespaces:**
- `claude-hub` - Project name
- `claude-squad` - Organization name
- `@yourorg` - Organization with @ prefix

❌ **Bad Namespaces:**
- `my-awesome-plugins` - Too long
- `plugins` - Too generic
- `ClaudeHub` - Wrong case

## Marketplace Configuration

### Category Names

Use these standard categories in marketplace.json:

- `workflow` - Task automation and generation
- `code-review` - Code quality and review
- `design` - UI/UX and visual design
- `tools` - Utilities and integrations
- `testing` - Test automation and quality
- `deployment` - CI/CD and deployment
- `documentation` - Docs generation and management

### Keywords

Include relevant keywords for search:
- Framework names: `rails`, `react`, `python`, `typescript`
- Technologies: `turbo`, `hotwire`, `graphql`
- Purposes: `automation`, `review`, `design`
- Patterns: `mvc`, `components`, `hooks`

## Version Numbering

Follow [Semantic Versioning](https://semver.org):

```
MAJOR.MINOR.PATCH
```

- **MAJOR** - Breaking changes
- **MINOR** - New features, backward compatible
- **PATCH** - Bug fixes

Examples:
- `0.1.0` - Initial development
- `1.0.0` - First stable release
- `1.1.0` - Added new commands
- `1.1.1` - Fixed a bug
- `2.0.0` - Renamed plugin (breaking change)

## File Naming

### Command Files
```
{command-name}.md
```

Examples:
- `rails-generate-model.md`
- `react-create-component.md`

### Agent Files
```
{agent-name}.md
```

Examples:
- `rails-reviewer.md`
- `rails-model-specialist.md`

### Configuration Files
```
plugin.json          # Plugin manifest
marketplace.json     # Marketplace configuration
package.json         # npm metadata
```

## Documentation Files

### Standard Files
```
README.md            # Plugin documentation
CHANGELOG.md         # Version history
LICENSE              # License file
CONTRIBUTING.md      # Contribution guide
MIGRATION_GUIDE.md   # Migration instructions
```

## Consistency Checklist

Before creating or renaming a plugin:

- [ ] Plugin name follows `{framework}-{purpose}` format
- [ ] Plugin name uses kebab-case
- [ ] Commands follow `{framework}-{verb}-{noun}` format
- [ ] Commands use approved verbs (generate, create, add, setup, etc.)
- [ ] Agents follow `{framework}-{role}` format
- [ ] Agent names use singular nouns
- [ ] No redundant suffixes (-agent, -plugin, etc.)
- [ ] Framework prefix for discoverability
- [ ] Category assigned in marketplace.json
- [ ] Keywords included for search
- [ ] Version follows semantic versioning
- [ ] All files use kebab-case

## Examples by Category

### Workflow Plugins
- `rails-generators`
- `rails-advanced-workflow`
- `react-typescript-workflow`
- `python-fastapi-workflow`
- `go-api-generators`

### Code Review Agents
- `rails-code-reviewer`
- `react-typescript-reviewer`
- `python-reviewer`
- `go-reviewer`

### Design Agents
- `ui-ux-designer`
- `component-designer`
- `responsive-designer`

### Specialized Agents
- `rails-model-specialist`
- `rails-controller-specialist`
- `react-hook-specialist`
- `api-specialist`

### Tools & Integrations
- `rails-mcp-servers`
- `docker-deployment`
- `github-actions`

## Evolution of Conventions

These conventions were established through practical experience:

**v0.1.0 - Initial:**
- `rails-workflow`
- `rails-dev-workflow`
- `rails-code-review-agent`

**v0.2.0 - Improved:**
- `rails-generators` (clearer purpose)
- `rails-advanced-workflow` (disambiguation)
- `rails-code-reviewer` (removed redundancy)

## Questions?

When in doubt:
1. Check existing plugins for patterns
2. Use the most specific, clearest name
3. Follow the format: `{framework}-{verb/role}-{noun}`
4. Test discoverability: Can users find it by typing `/{framework}`?
5. Avoid abbreviations unless universally understood

---

**Remember:** Good naming is about clarity, consistency, and discoverability. When users type `/ rails` or `/react`, they should see all relevant commands immediately.
