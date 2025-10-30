# Installing Claudy Plugins

This guide explains how to install and use Claudy plugins with Claude Code.

## Prerequisites

- Claude Code CLI installed
- Access to the Claudy marketplace repository

## Installation Methods

### Method 1: Interactive Plugin Menu (Recommended)

1. Open Claude Code in your project:

```bash
cd your-project
claude
```

2. Open the plugin menu:

```
/plugin
```

3. Browse available Claudy plugins and select ones to install

### Method 2: Direct Installation

Install a specific plugin directly:

```bash
# Install Rails workflow plugin
/plugin install rails-workflow@claudy

# Install React TypeScript workflow plugin
/plugin install react-typescript-workflow@claudy

# Install code review agents
/plugin install rails-code-review-agent@claudy
/plugin install react-typescript-code-review-agent@claudy

# Install UI/UX design agent
/plugin install ui-ux-design-agent@claudy
```

## Marketplace Setup

Before you can install Claudy plugins, you need to configure the marketplace:

### Option 1: Via Git Repository

1. Clone the Claudy repository:

```bash
git clone https://github.com/yourusername/claudy.git
```

2. Configure Claude Code to use the local marketplace:

```bash
# Point to the cloned repository
# The marketplace.json is in .claude-plugin/marketplace.json
```

### Option 2: Via Remote URL

Configure Claude Code to use the remote marketplace directly:

```bash
# Use GitHub raw URL or your hosted marketplace URL
```

## Managing Installed Plugins

### List Installed Plugins

```bash
/plugin list
```

### Enable/Disable Plugins

```bash
# Disable a plugin temporarily
/plugin disable rails-workflow@claudy

# Re-enable a plugin
/plugin enable rails-workflow@claudy
```

### Uninstall Plugins

```bash
/plugin uninstall rails-workflow@claudy
```

## Using Installed Plugins

### Workflow Plugins (Commands)

After installation, workflow plugins provide slash commands:

**Rails Workflow:**

```bash
/rails-generate-model User name:string email:string
/rails-generate-controller Posts index show create
/rails-add-turbo-stream
/rails-add-service-object
/rails-setup-rspec
/rails-add-api-endpoint
```

**React TypeScript Workflow:**

```bash
/react-create-component Button
/react-create-hook useApi
/react-setup-context ThemeContext
/react-setup-testing
/react-add-form-handling
/react-add-data-fetching
```

### Agent Plugins

Agent plugins are automatically available and can be invoked:

**Rails Code Review Agent:**

- Automatically invoked when reviewing Rails code
- Manually invoke: "Review my Rails code"

**React TypeScript Code Review Agent:**

- Automatically invoked when reviewing React/TypeScript code
- Manually invoke: "Review my React component"

**UI/UX Design Agent:**

- Invoke for design tasks: "Help me design a dashboard"
- Iterative refinement: "Improve the spacing in this layout"

## Verifying Installation

1. Check if commands are available:

```bash
/help
```

This should show all installed plugin commands.

2. Test a command:

```bash
# For Rails projects
/rails-generate-model Test name:string

# For React projects
/react-create-component TestComponent
```

## Troubleshooting

### Plugin Not Found

If you get "plugin not found" error:

1. Verify marketplace is configured correctly
2. Check plugin name spelling
3. Ensure you're using the correct marketplace name (@claudy)

### Commands Not Appearing

If commands don't appear after installation:

1. Restart Claude Code
2. Run `/help` to refresh command list
3. Check plugin is enabled: `/plugin list`

### Agent Not Responding

If an agent doesn't respond:

1. Try explicit invocation: "Invoke the [agent-name] agent"
2. Check agent is installed: `/plugin list`
3. Ensure you're in the right context (Rails project for Rails agent, etc.)

## Updating Plugins

To update to the latest version:

1. Uninstall the old version:

```bash
/plugin uninstall plugin-name@claudy
```

2. Install the new version:

```bash
/plugin install plugin-name@claudy
```

## Multiple Projects

Plugins are installed per-project. To use the same plugins across projects:

1. Install in each project separately, OR
2. Create a project template with plugins pre-installed

## Best Practices

1. **Start Small**: Install one plugin at a time to learn its features
2. **Read Documentation**: Check each plugin's README for usage examples
3. **Use Help**: Run `/help` frequently to see available commands
4. **Provide Feedback**: Report issues and suggestions to improve plugins

## Getting Help

- **Plugin Documentation**: Check README in each plugin directory
- **Command Help**: Most commands have built-in examples
- **Community**: GitHub Discussions for questions
- **Issues**: GitHub Issues for bug reports

## Next Steps

1. [Browse Available Plugins](README.md#available-plugins)
2. [Learn Plugin Development](docs/best-practices/PLUGIN_GUIDELINES.md)
3. [Contribute New Plugins](CONTRIBUTING.md)

---

Happy coding with Claudy plugins!
