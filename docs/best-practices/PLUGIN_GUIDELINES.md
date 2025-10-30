# Claude Code Plugin Development Best Practices

This guide outlines best practices for developing high-quality Claude Code plugins based on official documentation and observed patterns.

## Plugin Architecture

### Directory Structure

Claude Code plugins follow this official structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest (REQUIRED)
├── commands/              # Slash commands
│   └── command-name.md
├── agents/                # Custom agents
│   └── agent-name.md
├── skills/                # Agent skills (optional)
│   └── SKILL.md
└── hooks/                 # Event hooks (optional)
    └── hooks.json
```

### Plugin Manifest (plugin.json)

Every plugin **must** include a `.claude-plugin/plugin.json` manifest:

```json
{
  "name": "plugin-name",
  "description": "Brief description of what the plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name",
    "url": "https://yoursite.com"
  },
  "keywords": ["keyword1", "keyword2"],
  "categories": ["workflow", "agent", "utility"],
  "requirements": {
    "framework": ">=7.0.0"
  }
}
```

### Plugin Types

1. **Workflow Plugins** - Automate common development tasks
2. **Agent Plugins** - Specialized AI agents for specific domains
3. **Framework Integrations** - Framework-specific tooling and conventions
4. **Utilities** - Helper commands and tools
5. **Code Review Agents** - Quality assurance and pattern enforcement

## Command Development

### Command File Format

Commands are defined in markdown files under `.claude/commands/`:

```markdown
# command-name

Brief description of what this command does

---

The actual prompt/instructions that will be executed when the command is invoked.
This can include:
- Multi-line instructions
- Context about the task
- Expected behavior
```

### Command Naming Conventions

- Use kebab-case for command names
- Be descriptive but concise
- Prefix framework-specific commands (e.g., `rails-generate-model`, `react-create-component`)

### Command Best Practices

1. **Clear Instructions**: Write explicit, actionable prompts
2. **Context Awareness**: Include relevant context about project structure
3. **Error Handling**: Anticipate edge cases in instructions
4. **Testing Guidance**: Include test expectations when applicable
5. **Tool Preferences**: Specify preferred tools (Read over cat, Edit over sed)

Example:

```markdown
# rails-scaffold-resource

Generate a complete Rails resource with model, controller, views, and tests

---

Create a new Rails resource following these steps:

1. Generate the model with appropriate fields and validations
2. Create RESTful controller with standard actions
3. Generate view templates for index, show, new, edit
4. Add routes to config/routes.rb
5. Create RSpec tests for model and controller
6. Run migrations if needed

Follow Rails conventions:
- Use strong parameters
- Add appropriate validations
- Include scopes and associations where logical
- Use partials for shared view logic
```

## Agent Development

### Agent File Format

Agents are defined in markdown files under `.claude/agents/`:

```markdown
# agent-name

Description of the agent's purpose and when to use it

## Instructions

Detailed instructions for the agent including:
- Primary responsibilities
- When to be invoked
- How to approach tasks
- What to prioritize

## Available Tools

- Tool 1
- Tool 2

## Examples

<example>
Context: Situation description
user: "User request"
assistant: "Agent response"
<commentary>
Explanation of why this approach was taken
</commentary>
</example>
```

### Agent Best Practices

1. **Specialized Focus**: Agents should have clear, narrow domains
2. **Proactive Invocation**: Specify when agents should be auto-invoked
3. **Tool Mastery**: List and explain tool usage patterns
4. **Example-Driven**: Provide diverse, realistic examples
5. **Context Awareness**: Include project-specific conventions

### Agent Patterns

**Code Review Agent Pattern**:

- Define quality standards
- Specify review checklist
- Include framework-specific patterns
- Provide actionable feedback format

**Framework Agent Pattern**:

- Enforce framework conventions
- Detect anti-patterns
- Suggest idiomatic solutions
- Reference framework best practices

## Hook Development

### Hook Types

1. **pre-commit**: Validation before commits
2. **post-commit**: Actions after successful commits
3. **pre-push**: Checks before pushing
4. **tool-call**: Intercept specific tool calls

### Hook Best Practices

1. **Fast Execution**: Keep hooks lightweight
2. **Clear Feedback**: Provide actionable error messages
3. **Exit Codes**: Use proper exit codes for success/failure
4. **Non-Blocking**: Avoid long-running operations

## Testing Your Plugins

### Manual Testing

1. Create a test project with your plugin installed
2. Invoke commands and verify behavior
3. Test agent invocation scenarios
4. Verify hooks trigger correctly

### Test Checklist

- [ ] Commands parse and execute correctly
- [ ] Agents invoke at appropriate times
- [ ] Tools are used correctly
- [ ] Output is clear and helpful
- [ ] Error cases are handled gracefully
- [ ] Performance is acceptable

## Common Pitfalls

### Anti-Patterns to Avoid

1. **Overly Broad Agents**: Agents should be specialized
2. **Vague Instructions**: Be explicit and detailed
3. **Ignoring Context**: Consider project-specific needs
4. **Tool Misuse**: Use specialized tools over bash when possible
5. **Missing Examples**: Always provide usage examples
6. **No Error Handling**: Anticipate failure scenarios

### Performance Considerations

1. Use Task tool for exploratory searches
2. Make parallel tool calls when possible
3. Read files once, not repeatedly
4. Use Grep/Glob efficiently with proper patterns

## Documentation Requirements

Every plugin should include:

1. **README.md**: Overview, installation, usage
2. **EXAMPLES.md**: Real-world usage scenarios
3. **CHANGELOG.md**: Version history
4. **LICENSE**: Open source license

## Version Management

Follow semantic versioning (semver):

- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

## Distribution

### Plugin Package Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # REQUIRED manifest
├── commands/              # Slash commands
├── agents/                # AI agents
├── skills/                # Skills (optional)
├── hooks/                 # Hooks (optional)
├── README.md              # Plugin documentation
├── EXAMPLES.md            # Usage examples
├── package.json           # npm metadata (optional)
└── LICENSE                # License file
```

### Installation Methods

Plugins are installed via the Claude Code plugin system:

1. **Interactive Menu**:

   ```bash
   /plugin
   ```

   Browse available plugins and install through a guided interface.

2. **Direct Installation**:

   ```bash
   /plugin install plugin-name@marketplace-name
   ```

3. **Management Commands**:

   ```bash
   /plugin enable plugin-name@marketplace-name
   /plugin disable plugin-name@marketplace-name
   /plugin uninstall plugin-name@marketplace-name
   ```

### Marketplace Configuration

To distribute plugins via a marketplace, create `.claude-plugin/marketplace.json`:

```json
{
  "name": "marketplace-name",
  "owner": { "name": "Owner Name" },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./path/to/plugin",
      "description": "Plugin description"
    }
  ]
}
```

## Framework-Specific Guidelines

### Rails Plugins

- Follow Rails naming conventions
- Use Rails generators where appropriate
- Respect MVC architecture
- Include RSpec/Minitest support
- Consider Hotwire/Turbo patterns

### React/TypeScript Plugins

- Use TypeScript type safety
- Follow React best practices
- Support modern React patterns (hooks, suspense)
- Include component generation utilities
- Consider testing library integration

## Community Guidelines

1. **Open Source**: Use permissive licenses
2. **Documentation**: Comprehensive and clear
3. **Examples**: Include real-world scenarios
4. **Maintenance**: Regular updates and bug fixes
5. **Feedback**: Accept and address community input

## Resources

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Plugin Examples](../examples/)
- [Community Forum](https://github.com/anthropics/claude-code/discussions)
