# Claude Hub Quick Start Guide

Get started with Claude Hub plugins in 5 minutes!

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/claude-hub.git
cd claude-hub

# 2. Verify everything is ready
./scripts/verify-marketplace.sh
```

## Using Plugins with Claude Code

### Install Plugins

```bash
# Open Claude Code in your project
cd your-project
claude

# Install plugins interactively
/plugin

# Or install specific plugins directly
/plugin install rails-workflow@claude-hub
/plugin install react-typescript-workflow@claude-hub
```

## Rails Development

### Available Commands

```bash
/rails-generate-model User name:string email:string
/rails-generate-controller Posts index show create
/rails-add-turbo-stream
/rails-add-service-object
/rails-setup-rspec
/rails-add-api-endpoint
```

### Code Review

Just ask: "Review my Rails code" - The Rails code review agent will automatically analyze your changes.

## React/TypeScript Development

### Available Commands

```bash
/react-create-component Button
/react-create-hook useApi
/react-setup-context ThemeContext
/react-setup-testing
/react-add-form-handling
/react-add-data-fetching
```

### Code Review

Just ask: "Review my React component" - The React/TypeScript code review agent will provide feedback.

## UI/UX Design

### Usage

```bash
# Design tasks
"Help me design a dashboard for analytics"
"Create a modern login form"
"Make this component more accessible"

# Iterative refinement
"The spacing feels off"
"Can you improve the visual hierarchy?"
"Try a different color scheme"
```

## Management Commands

```bash
# List installed plugins
/plugin list

# Enable/disable plugins
/plugin enable plugin-name@claude-hub
/plugin disable plugin-name@claude-hub

# Uninstall plugins
/plugin uninstall plugin-name@claude-hub

# View available commands
/help
```

## Developer Tools

```bash
# List all available plugins
./scripts/list-plugins.sh

# Show plugin details
./scripts/install-plugin.sh rails-workflow

# Validate a plugin
./scripts/validate-plugin.sh rails-workflow

# Verify entire marketplace
./scripts/verify-marketplace.sh
```

## Examples

### Example 1: Rails Model Generation

```bash
# Request
/rails-generate-model Post title:string body:text user:references published:boolean

# Claude Code will:
1. Generate the model with validations
2. Create database migration
3. Add associations (belongs_to :user)
4. Create RSpec tests
5. Add appropriate indexes
```

### Example 2: React Component Creation

```bash
# Request
/react-create-component UserCard with avatar, name, and email props

# Claude Code will:
1. Create UserCard component with TypeScript
2. Define prop interfaces
3. Add JSDoc documentation
4. Create component tests
5. Generate example usage
```

### Example 3: Code Review

```bash
# In Claude Code
"I just updated the User model. Can you review it?"

# Rails Code Review Agent will:
1. Check validations
2. Review associations
3. Identify N+1 queries
4. Suggest improvements
5. Verify test coverage
```

## Common Workflows

### Starting a New Rails Feature

```bash
1. /rails-generate-model Feature name:string
2. /rails-generate-controller Features index show create
3. /rails-add-turbo-stream
4. "Review my Rails code"
```

### Starting a New React Component

```bash
1. /react-create-component FeatureName
2. /react-add-form-handling
3. /react-setup-testing
4. "Review my React component"
```

### UI Design Iteration

```bash
1. "Design a user dashboard"
2. (Claude creates initial design)
3. "Make it more modern"
4. (Claude refines)
5. "Improve accessibility"
6. (Claude adds ARIA attributes)
```

## Troubleshooting

### Plugin not found?

```bash
# Check marketplace is configured
/plugin list

# Verify plugin name
./scripts/list-plugins.sh
```

### Commands not appearing?

```bash
# Restart Claude Code
# Then check available commands
/help
```

### Need help with a command?

```bash
# Most commands have examples
# Just use them with descriptive requests
/rails-generate-model User with authentication
```

## Next Steps

1. 📚 Read full documentation: [README.md](README.md)
2. 🎯 Learn plugin development: [PLUGIN_GUIDELINES.md](docs/best-practices/PLUGIN_GUIDELINES.md)
3. 🤝 Contribute: [CONTRIBUTING.md](CONTRIBUTING.md)
4. 📦 Check status: [STATUS.md](STATUS.md)

## Get Help

- **Commands**: Use `/help` in Claude Code
- **Issues**: GitHub Issues
- **Questions**: GitHub Discussions
- **Examples**: Check plugin README files

---

**Happy coding with Claude Hub!** 🚀
