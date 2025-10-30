# Contributing to Claudy

Thank you for your interest in contributing to Claudy! This document provides guidelines and instructions for contributing to the plugin marketplace.

## How to Contribute

There are several ways to contribute:

1. **Create new plugins** - Add plugins for new frameworks or workflows
2. **Improve existing plugins** - Enhance commands or agents
3. **Fix bugs** - Report and fix issues
4. **Improve documentation** - Help others understand the plugins
5. **Share feedback** - Suggest improvements

## Getting Started

### Prerequisites

- Node.js 18+
- Git
- Claude Code CLI
- Familiarity with markdown
- Understanding of the target framework/tool

### Setup Development Environment

1. Fork and clone the repository:

```bash
git clone https://github.com/yourusername/claudy.git
cd claudy
```

2. Install dependencies:

```bash
npm install
```

3. Explore existing plugins:

```bash
./scripts/list-plugins.sh
```

## Creating a New Plugin

### Step 1: Plan Your Plugin

Before creating a plugin, consider:

- **Purpose**: What problem does it solve?
- **Scope**: Is it focused and well-defined?
- **Type**: Command-based, agent-based, or both?
- **Framework**: What technology does it support?

### Step 2: Create Plugin Structure

```bash
mkdir -p plugins/my-plugin/.claude/{commands,agents}
mkdir -p plugins/my-plugin/examples
```

### Step 3: Create package.json

```bash
cat > plugins/my-plugin/package.json << 'EOF'
{
  "name": "@claudy/my-plugin",
  "version": "0.1.0",
  "description": "Brief description of your plugin",
  "keywords": ["claude-code", "plugin", "your-framework"],
  "author": "Your Name",
  "license": "MIT"
}
EOF
```

### Step 4: Add Commands or Agents

#### For Commands

Create markdown files in `.claude/commands/`:

```markdown
# command-name

Brief description of what this command does

---

Detailed instructions that Claude Code will execute when the command is invoked.

Include:
- Step-by-step instructions
- Expected behavior
- Error handling
- Example patterns
```

#### For Agents

Create markdown files in `.claude/agents/`:

```markdown
# agent-name

Brief description of the agent's purpose

## Instructions

Detailed instructions for the agent including:
- Primary responsibilities
- When to be invoked
- How to approach tasks
- What to prioritize

## Available Tools

List of tools the agent can use

## Examples

<example>
Context: Situation description
user: "User request"
assistant: "Agent response"
<commentary>Explanation</commentary>
</example>
```

### Step 5: Create README.md

Every plugin must have a comprehensive README:

```markdown
# Plugin Name

Description of the plugin

## Installation

Installation instructions

## Usage

How to use the plugin

## Features

List of features

## Requirements

Dependencies and requirements

## Examples

Usage examples

## License

MIT License
```

### Step 6: Add Examples

Create practical examples in the `examples/` directory showing real-world usage.

### Step 7: Validate Your Plugin

```bash
./scripts/validate-plugin.sh my-plugin
```

### Step 8: Test Your Plugin

1. Install to a test project:

```bash
./scripts/install-plugin.sh my-plugin /path/to/test/project
```

2. Test all commands/agents
3. Verify documentation accuracy
4. Check for edge cases

## Plugin Quality Standards

### Documentation

- [ ] Clear, concise README
- [ ] Installation instructions
- [ ] Usage examples
- [ ] Feature list
- [ ] Requirements specified

### Commands

- [ ] Clear command names (kebab-case)
- [ ] Detailed instructions
- [ ] Error handling guidance
- [ ] Example patterns included
- [ ] Framework conventions followed

### Agents

- [ ] Clear purpose and scope
- [ ] Detailed instructions
- [ ] Multiple examples provided
- [ ] Tool usage documented
- [ ] Invocation triggers specified

### Code Quality

- [ ] Follows best practices
- [ ] No security vulnerabilities
- [ ] Performance considered
- [ ] Accessibility included (for UI)
- [ ] Testing encouraged

## Pull Request Process

1. **Fork the repository**

2. **Create a feature branch**:

```bash
git checkout -b feature/my-plugin
```

3. **Make your changes**:
   - Create or modify plugins
   - Update documentation
   - Add examples

4. **Validate your changes**:

```bash
./scripts/validate-plugin.sh my-plugin
npm run lint
```

5. **Commit with clear messages**:

```bash
git commit -m "feat: Add my-plugin for X framework

- Add command for Y
- Add agent for Z
- Include usage examples"
```

6. **Push to your fork**:

```bash
git push origin feature/my-plugin
```

7. **Create Pull Request**:
   - Provide clear description
   - Link related issues
   - Include testing notes
   - Add screenshots if applicable

## Commit Message Guidelines

Follow conventional commits:

- `feat:` - New feature or plugin
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test additions or changes
- `chore:` - Maintenance tasks

Examples:

```
feat: Add Python FastAPI workflow plugin
fix: Correct Rails model validation command
docs: Update React plugin README with new examples
```

## Code Review Process

All contributions go through code review:

1. **Automated checks** run on PR
2. **Maintainer review** for quality and fit
3. **Feedback** provided for improvements
4. **Approval** and merge when ready

### Review Criteria

- Code quality and clarity
- Documentation completeness
- Best practices adherence
- Testing thoroughness
- Security considerations
- Performance implications

## Best Practices

### Commands

1. **Be specific**: Clear, actionable instructions
2. **Include context**: Explain the "why"
3. **Handle errors**: Anticipate edge cases
4. **Follow conventions**: Use framework best practices
5. **Provide examples**: Show usage patterns

### Agents

1. **Define scope**: Clear, focused purpose
2. **Provide examples**: Multiple realistic scenarios
3. **Document triggers**: When to invoke
4. **List tools**: What tools to use
5. **Be educational**: Explain reasoning

### Documentation

1. **Be clear**: Simple, understandable language
2. **Be complete**: Cover all features
3. **Be practical**: Real-world examples
4. **Be current**: Keep up to date
5. **Be helpful**: Anticipate questions

## Testing

### Manual Testing

1. Install plugin to test project
2. Test all commands/agents
3. Verify expected behavior
4. Check edge cases
5. Test error scenarios
6. Validate documentation

### Test Checklist

- [ ] Commands execute correctly
- [ ] Agents invoke appropriately
- [ ] Documentation accurate
- [ ] Examples work
- [ ] Error handling works
- [ ] Performance acceptable

## Getting Help

Need help contributing?

- **Documentation**: Check [Plugin Guidelines](docs/best-practices/PLUGIN_GUIDELINES.md)
- **Examples**: Review existing plugins
- **Discussion**: Open a discussion on GitHub
- **Issues**: Ask questions in issues

## Plugin Naming

- Use kebab-case for plugin names
- Be descriptive but concise
- Include framework name if applicable
- Examples:
  - `rails-workflow`
  - `react-typescript-code-review-agent`
  - `python-fastapi-workflow`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing private information

## Recognition

Contributors will be:

- Listed in plugin READMEs (if desired)
- Acknowledged in release notes
- Credited in CONTRIBUTORS.md

## Questions?

Don't hesitate to ask:

- Open a discussion on GitHub
- Comment on existing issues
- Reach out to maintainers

Thank you for contributing to Claudy!
