# Claudy - Claude Code Plugin Marketplace

**Project Type**: Monorepo / Plugin Marketplace
**Version**: 0.1.0
**Purpose**: Curated collection of Claude Code plugins for Rails, React, code review, and UI/UX workflows

---

## Project Overview

Claudy is a comprehensive marketplace of Claude Code plugins that enhance developer productivity. Each plugin follows official Claude Code plugin structure and best practices.

**Key Features**:
- Plugin marketplace for Claude Code
- Rails workflow automation (generators, API patterns)
- React/TypeScript development workflows
- Code review agents (Rails, React)
- UI/UX design agents
- MCP server integrations

---

## Project Structure

```
claudy/
├── plugins/                    # All plugins
│   ├── rails-workflow/        # Rails 8 workflow with 7 agents
│   └── rails-mcp-servers/     # Rails documentation MCP
├── scripts/                    # Plugin utilities
│   ├── install-plugin.sh
│   ├── validate-plugin.sh
│   └── list-plugins.sh
├── docs/                       # Plugin guidelines
└── .claude/                    # Project context (this file)
```

---

## Development Guidelines

### Plugin Structure

Every plugin must follow this structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Manifest (required)
├── commands/              # Slash commands (*.md)
├── agents/                # AI agents (*.md)
├── README.md              # Documentation
└── examples/              # Usage examples
```

### Plugin Standards

1. **Manifest Required**: Every plugin has `.claude-plugin/plugin.json`
2. **Documentation**: Comprehensive README with examples
3. **Validation**: Use `./scripts/validate-plugin.sh` before committing
4. **Naming**: Use kebab-case for plugin names
5. **Versioning**: Follow semantic versioning (semver)

### Code Conventions

**File Naming**:
- Commands: `command-name.md` in `commands/`
- Agents: `agent-name.md` in `agents/`
- Plugin manifest: `.claude-plugin/plugin.json`

**Documentation**:
- Every plugin must have README.md
- Include installation instructions
- Provide usage examples
- Document all commands and agents

**Git Workflow**:
- Work on feature branches
- Run validation before commits
- Keep commits focused and atomic
- Use descriptive commit messages

---

## Plugin Categories

### 1. Workflow Automation
Plugins that automate development tasks via slash commands.
- rails-workflow (7 agents, 5 commands)

### 2. Code Review Agents
AI agents for code quality and conventions.

### 3. MCP Integrations
Model Context Protocol servers for documentation and tools.
- rails-mcp-servers (Rails docs + filesystem)

---

## Available Commands

**Plugin Management**:
- `./scripts/list-plugins.sh` - List all plugins
- `./scripts/validate-plugin.sh <name>` - Validate plugin
- `./scripts/install-plugin.sh <name> <target>` - Install plugin

**Development**:
- Validation runs automatically on plugin.json changes
- Use bash scripts for plugin utilities
- Test plugins before submitting PRs

---

## Integration with Agentic Substrate

This project works with the system-wide Agentic Substrate (`~/.claude/`):

**Use Agentic Substrate for**:
- `/workflow` - Feature development on plugins
- `/research` - Library documentation research
- `/plan` - Implementation planning
- `/implement` - Code execution with TDD

**Use Project Context for**:
- Plugin-specific guidelines
- Marketplace structure understanding
- Plugin validation workflows
- Development standards

---

## Quality Standards

### Plugin Quality Checklist

Before submitting plugins:
- [ ] Manifest (plugin.json) is valid JSON
- [ ] README.md exists with examples
- [ ] Commands are well-documented
- [ ] Agents have clear prompts
- [ ] Validation script passes
- [ ] Examples demonstrate all features
- [ ] Follows naming conventions

### Code Review Focus

When reviewing plugin code:
- **Structure**: Follows official plugin structure
- **Documentation**: Clear, comprehensive README
- **Examples**: Real-world usage shown
- **Conventions**: Consistent naming and organization
- **Validation**: Passes validation scripts

---

## Common Tasks

### Creating a New Plugin

```bash
# 1. Create plugin directory structure
mkdir -p plugins/my-plugin/.claude-plugin
mkdir -p plugins/my-plugin/{commands,agents,examples}

# 2. Create manifest
cat > plugins/my-plugin/.claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "description": "Plugin description",
  "version": "0.1.0",
  "author": {"name": "Your Name"},
  "keywords": ["keyword1"],
  "categories": ["workflow"]
}
EOF

# 3. Create README
cat > plugins/my-plugin/README.md << 'EOF'
# My Plugin

Description here...
EOF

# 4. Validate
./scripts/validate-plugin.sh my-plugin
```

### Testing a Plugin Locally

```bash
# 1. Validate plugin structure
./scripts/validate-plugin.sh plugin-name

# 2. Install to test project
./scripts/install-plugin.sh plugin-name /path/to/test/project

# 3. Test commands in Claude Code
cd /path/to/test/project
# Use plugin commands
```

### Updating Plugin Documentation

When updating plugin features:
1. Update plugin README.md
2. Update main README.md (this file's parent)
3. Update examples/
4. Increment version in plugin.json
5. Test thoroughly before committing

---

## Technical Details

### Technologies

**Languages**:
- Markdown (plugin definitions)
- JSON (manifests)
- Bash (utility scripts)

**Tools**:
- Claude Code CLI
- Git
- jq (JSON validation)
- Standard Unix utilities

### Plugin Manifest Schema

```json
{
  "name": "string (kebab-case)",
  "description": "string",
  "version": "semver string",
  "author": {
    "name": "string",
    "email": "string (optional)"
  },
  "keywords": ["array", "of", "strings"],
  "categories": ["array"]
}
```

---

## Best Practices

### DO

✅ Follow official Claude Code plugin structure
✅ Validate plugins before committing
✅ Include comprehensive documentation
✅ Provide real-world examples
✅ Use semantic versioning
✅ Test plugins thoroughly
✅ Keep plugins focused (single responsibility)

### DON'T

❌ Skip validation scripts
❌ Commit without testing
❌ Create plugins without documentation
❌ Break existing plugin structure
❌ Use generic names
❌ Skip version updates
❌ Mix multiple concerns in one plugin

---

## Troubleshooting

### Plugin Validation Fails

**Issue**: `validate-plugin.sh` reports errors

**Solutions**:
1. Check plugin.json is valid JSON
2. Verify all required fields present
3. Ensure file structure matches spec
4. Check README.md exists

### Plugin Installation Issues

**Issue**: Plugin won't install to target project

**Solutions**:
1. Verify plugin structure is correct
2. Check target directory exists
3. Ensure you have write permissions
4. Run validation first

---

## Resources

**Documentation**:
- Main README: `/README.md`
- Plugin Guidelines: `/docs/best-practices/PLUGIN_GUIDELINES.md`
- Individual plugin READMEs in `/plugins/*/README.md`

**Scripts**:
- List plugins: `./scripts/list-plugins.sh`
- Validate: `./scripts/validate-plugin.sh`
- Install: `./scripts/install-plugin.sh`

**Agentic Substrate Integration**:
- User context: `~/.claude/CLAUDE.md`
- System agents: `~/.claude/agents/`
- Workflow commands: `/workflow`, `/research`, `/plan`, `/implement`

---

## Workflow Integration

### Feature Development

For adding new plugins or features:

```bash
# Use Agentic Substrate for complete automation
/workflow Add new Python plugin with FastAPI support

# Or step-by-step
/research FastAPI 0.115.x official docs
/plan Python plugin implementation
/implement
```

### Plugin Enhancement

For improving existing plugins:

```bash
# Research first
/research Rails 8 ActionMailbox features

# Plan changes
/plan Add ActionMailbox support to rails-workflow plugin

# Implement with TDD
/implement
```

---

## Notes

- This project uses system-wide Agentic Substrate from `~/.claude/`
- Project-level context (this file) focuses on plugin marketplace specifics
- See `knowledge-core.md` for accumulated learnings and patterns
- Use `/context optimize` periodically to maintain context health

---

**Version**: 1.0.0 (Context initialization)
**Last Updated**: 2025-10-30
**Compatible With**: Agentic Substrate v3.0
