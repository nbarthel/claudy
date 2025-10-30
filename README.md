# Claudy - Claude Code Plugin Marketplace

A comprehensive marketplace of Claude Code plugins for software development workflows. This monorepo contains high-quality plugins for Rails, React/TypeScript, code review, UI/UX design, and more.

## Overview

Claudy provides a curated collection of Claude Code plugins that follow best practices and enhance developer productivity. Each plugin is designed to work seamlessly with Claude Code CLI and can be easily installed into your projects.

## Available Plugins

### Workflow Plugins

#### Rails Workflow (`rails-workflow`)

Comprehensive Rails 8 development with specialized AI agents for models, controllers, services, tests, and devops. Includes multi-agent orchestration and safety hooks.

**Features:**

- 7 specialized agents (architect, models, controllers, views, services, tests, devops)
- 5 slash commands (swarm, scaffold, refactor, analyze, mcp-status)
- Multi-agent coordination via architect
- Rails 8 best practices with Solid Queue, Action Cable
- Pre-agent validation and pre-commit safety hooks
- RSpec testing patterns

**Agents:** 7 specialized agents
**Commands:** 5 workflow commands
**Hooks:** 2 safety hooks
**Installation:** `./scripts/install-plugin.sh rails-workflow /path/to/rails/project`

---

### MCP Integrations

#### Rails MCP Servers (`rails-mcp-servers`)

Model Context Protocol servers providing Rails documentation and filesystem access.

**Features:**

- Rails documentation search and retrieval
- Rails API reference access
- Filesystem operations for Rails projects
- Integration with Claude Code MCP support

**Installation:** `./scripts/install-plugin.sh rails-mcp-servers /path/to/project`

---

## Quick Start

### Installation

1. Clone this repository:

```bash
git clone https://github.com/yourusername/claudy.git
cd claudy
```

2. Configure the Claudy marketplace in Claude Code (see Marketplace Setup below)

3. List available plugins:

```bash
./scripts/list-plugins.sh
```

4. Install plugins to your project:

```bash
# Install a plugin to your project
./scripts/install-plugin.sh rails-workflow /path/to/your/rails/project

# Or install from within the target project
cd /path/to/your/rails/project
/path/to/claudy/scripts/install-plugin.sh rails-workflow .
```

### Marketplace Setup

To use the Claudy plugin marketplace with Claude Code:

1. In Claude Code, configure the Claudy marketplace by pointing to this repository
2. The marketplace configuration is in `.claude-plugin/marketplace.json`
3. Once configured, you can browse and install plugins using `/plugin`

### Example: Installing Rails Workflow Plugin

```bash
# In your Rails project, install the plugin
cd ~/projects/my-rails-app
/path/to/claudy/scripts/install-plugin.sh rails-workflow .

# Use the commands in Claude Code
/rails-swarm Build a complete User authentication system

# Or use specialized agents
@rails-architect Design the authentication architecture
```

## Plugin Structure

Each plugin follows the official Claude Code plugin structure:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json        # Plugin manifest (required)
├── commands/              # Slash commands (*.md files)
├── agents/                # AI agents (*.md files)
├── skills/                # Agent skills (optional)
├── hooks/                 # Event hooks (optional)
├── package.json           # npm metadata
├── README.md              # Plugin documentation
└── examples/              # Usage examples
```

### plugin.json Manifest

Every plugin must have a `.claude-plugin/plugin.json` manifest:

```json
{
  "name": "plugin-name",
  "description": "Plugin description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  },
  "keywords": ["keyword1", "keyword2"],
  "categories": ["category1"]
}
```

## Development

### Creating a New Plugin

1. Create plugin directory:

```bash
mkdir -p plugins/my-plugin/.claude/{commands,agents}
```

2. Add package.json:

```json
{
  "name": "@claudy/my-plugin",
  "version": "0.1.0",
  "description": "My awesome plugin",
  "keywords": ["claude-code", "plugin"]
}
```

3. Add commands or agents as markdown files

4. Create README.md with usage instructions

5. Validate your plugin:

```bash
./scripts/validate-plugin.sh my-plugin
```

### Plugin Development Guidelines

See [docs/best-practices/PLUGIN_GUIDELINES.md](docs/best-practices/PLUGIN_GUIDELINES.md) for comprehensive guidelines on:

- Command development
- Agent creation
- Best practices
- Testing
- Documentation

## Utilities

### List All Plugins

```bash
./scripts/list-plugins.sh
```

### Install a Plugin

```bash
./scripts/install-plugin.sh <plugin-name> <target-directory>
```

### Validate a Plugin

```bash
./scripts/validate-plugin.sh <plugin-name>
```

## Plugin Categories

### 1. Workflow Automation

Plugins that automate common development tasks through slash commands and specialized agents.

**Available:** rails-workflow

### 2. MCP Integrations

Model Context Protocol servers for documentation and tool access.

**Available:** rails-mcp-servers

## Best Practices

All plugins in this marketplace follow these principles:

1. **Clear Documentation**: Every plugin has comprehensive README
2. **Examples Included**: Real-world usage examples
3. **Best Practices**: Follow framework and language conventions
4. **Type Safety**: TypeScript where applicable
5. **Testing**: Encourage test coverage
6. **Accessibility**: WCAG compliance in UI plugins
7. **Performance**: Optimization considerations
8. **Security**: Security best practices enforced

## Contributing

We welcome contributions! To contribute:

1. Fork this repository
2. Create a new plugin or improve existing ones
3. Follow the plugin development guidelines
4. Validate your plugin with `./scripts/validate-plugin.sh`
5. Submit a pull request

### Contribution Guidelines

- Follow existing plugin patterns
- Include comprehensive documentation
- Provide usage examples
- Test your plugin thoroughly
- Update this README with plugin details

## Requirements

- Claude Code CLI
- Git
- Bash (for utility scripts)
- jq (for JSON validation in scripts)

## Project Structure

```
claudy/
├── plugins/                    # All plugins
│   ├── rails-workflow/        # Rails 8 workflow with 7 agents
│   └── rails-mcp-servers/     # Rails documentation MCP
├── docs/                       # Documentation
│   └── best-practices/         # Plugin guidelines
├── scripts/                    # Utility scripts
│   ├── install-plugin.sh
│   ├── validate-plugin.sh
│   └── list-plugins.sh
├── CLAUDE.md                   # Project context
└── README.md                   # This file
```

## Roadmap

Future plugins planned:

- [ ] Python/FastAPI workflow plugin
- [ ] Go development plugin
- [ ] Database migration helper
- [ ] API documentation generator
- [ ] Performance testing agent
- [ ] Security audit agent
- [ ] Docker/deployment utilities
- [ ] GraphQL schema builder

## Support

### Documentation

- [Plugin Guidelines](docs/best-practices/PLUGIN_GUIDELINES.md)
- Individual plugin READMEs in each plugin directory

### Getting Help

- GitHub Issues: [Report an issue](https://github.com/yourusername/claudy/issues)
- Discussions: [Community discussions](https://github.com/yourusername/claudy/discussions)

## License

MIT License - see [LICENSE](LICENSE) file

## Credits

Built for the Claude Code community by developers who love automation and great developer experiences.

## Version

0.1.0 - Initial release

## Changelog

See individual plugin READMEs for plugin-specific changes.

### v0.1.0 (Initial Release)

- Rails Workflow plugin with 7 agents, 5 commands, and 2 safety hooks
- Rails MCP Servers for documentation and filesystem access
- Utility scripts for plugin management (install, validate, list)
- Comprehensive documentation and examples

## Acknowledgments

Thanks to:

- Anthropic for Claude Code
- The Rails community for Rails conventions
- The React community for React patterns
- All contributors and users

---

**Start building better software with Claudy plugins!**

Get started: `./scripts/list-plugins.sh`
