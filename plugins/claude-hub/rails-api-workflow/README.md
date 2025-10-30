# Rails Dev Workflow Plugin

A comprehensive Rails development plugin inspired by [claude-on-rails](https://github.com/obie/claude-on-rails) that orchestrates specialized AI agents to build full-stack Rails features. Unlike claude-on-rails which uses the claude-swarm gem, this plugin uses native Claude Code agent capabilities.

## Overview

This plugin provides a team of specialized Rails agents that work together like a real development team.

### Highly Recommended: Install with MCP Servers

**For significantly enhanced capabilities**, also install the MCP servers plugin:

```bash
/plugin install rails-mcp-servers@claude-hub
```

**What You Get with MCP Servers:**

🚀 **Verification Against Official Docs**

- Agents verify patterns against Rails 8 documentation before implementing
- Ensures latest syntax and best practices
- Reduces hallucination and outdated patterns

🎯 **Project Pattern Matching**

- Agents analyze your existing code to match your style
- Consistent naming conventions across generated code
- Matches your validation patterns, test structure, and service patterns

⚡ **Enhanced Intelligence**

- Real-time access to Rails 8, Turbo, Stimulus, and Hotwire docs
- Filesystem operations to read and understand existing code
- Pattern detection across your codebase

**Example: With vs Without MCP Servers**

**Without MCP servers:**

```
You: "Create a Post model"
Agent: Creates model using general Rails knowledge
```

**With MCP servers:**

```
You: "Create a Post model"
Agent:
1. Checks Rails 8 model patterns in official docs
2. Reads your existing User model to match validation style
3. Verifies association syntax against current Rails docs
4. Creates model matching your project's exact patterns
```

**All agents work fully without MCP servers** - they're an enhancement, not a requirement. But with MCP servers, you get:

- ✅ Rails 8 specific features (encrypts, normalizes, Solid Queue)
- ✅ Code matching your existing patterns
- ✅ Verified against official documentation
- ✅ Up-to-date syntax and conventions

See [rails-mcp-servers](../rails-mcp-servers/README.md) for installation details.

## Specialized Agents

This plugin provides a team of specialized Rails agents that work together:

- **rails-architect**: Main coordinator, analyzes requests and delegates to specialists
- **rails-models**: Database design, migrations, ActiveRecord models, associations
- **rails-controllers**: RESTful controllers, routing, strong parameters, authorization
- **rails-views**: ERB templates, Turbo Streams, Stimulus, accessibility
- **rails-services**: Service objects, business logic extraction, transactions
- **rails-tests**: RSpec/Minitest setup, comprehensive test coverage
- **rails-devops**: Docker, Kamal, CI/CD, deployment configuration

## Installation

### Via Claude Code (Recommended)

```bash
# In your Rails project, open Claude Code
cd ~/projects/my-rails-app
claude

# Install the workflow plugin
/plugin install rails-dev-workflow@claude-hub

# Optional but recommended: Install MCP servers for enhanced capabilities
/plugin install rails-mcp-servers@claude-hub

# Verify installation
/help
```

### Manual Installation

```bash
# From your Rails project root
cp -r path/to/claude-hub/plugins/rails-dev-workflow/.claude-plugin .
cp -r path/to/claude-hub/plugins/rails-dev-workflow/agents .
cp -r path/to/claude-hub/plugins/rails-dev-workflow/commands .
```

## Available Commands

### `/rails-dev [request]`

Main entry point for Rails development. Analyzes your request and coordinates specialized agents.

**Examples:**

```
/rails-dev Add a blog feature with posts and comments
/rails-dev Create user authentication
/rails-dev Add API endpoints for posts
/rails-dev Implement real-time notifications with Turbo
```

**What it does:**

- Analyzes your natural language request
- Invokes the rails-architect agent
- Coordinates multiple specialists as needed
- Implements across all Rails layers (models, controllers, views, tests)

### `/rails-feature [feature name]`

Generate a complete full-stack Rails feature with all layers implemented.

**Examples:**

```
/rails-feature Post with comments and tags
/rails-feature User authentication with email confirmation
/rails-feature API endpoints for products
/rails-feature Real-time chat with Turbo Streams
```

**What it does:**

- Creates models with migrations
- Generates RESTful controllers
- Builds views with Turbo support
- Adds comprehensive tests
- Follows Rails conventions

### `/rails-refactor [description]`

Coordinate refactoring across Rails application layers.

**Examples:**

```
/rails-refactor The posts controller has too much logic
/rails-refactor Fix N+1 queries in the dashboard
/rails-refactor Extract authentication to a concern
/rails-refactor Move view logic to helpers
```

**What it does:**

- Analyzes existing code
- Identifies code smells
- Extracts service objects
- Optimizes queries
- Updates tests

## Agent Specializations

### rails-architect (Coordinator)

The architect analyzes your requests and coordinates other agents. It:

- Breaks down features into component tasks
- Determines which specialists to involve
- Sequences work when dependencies exist
- Runs agents in parallel when possible
- Ensures consistency across layers

**Invoke directly:**
You can also invoke specialized agents directly using the Task tool if you need focused work on a specific layer.

### rails-models (Data Layer)

Focuses on database design and ActiveRecord:

- Database schema design
- Safe, reversible migrations
- Model validations and associations
- Scopes and query optimization
- Database indexes for performance

**Best for:**

- Creating/modifying models
- Writing migrations
- Setting up associations
- Optimizing queries

### rails-controllers (HTTP Layer)

Handles request/response logic:

- RESTful controller actions
- Strong parameters
- Authorization
- Error handling
- API endpoints
- Turbo Stream responses

**Best for:**

- CRUD operations
- API development
- Request handling
- Authorization logic

### rails-views (Presentation Layer)

Creates user interfaces:

- ERB templates
- Turbo Frames and Streams
- Stimulus controllers
- Accessible forms
- Responsive design
- Modern Hotwire patterns

**Best for:**

- UI implementation
- Real-time features
- Interactive components
- Accessibility

### rails-services (Business Logic)

Extracts complex business logic:

- Service objects
- Multi-model operations
- Transaction management
- External API integration
- Background job coordination

**Best for:**

- Fat controller refactoring
- Complex workflows
- Payment processing
- External integrations

### rails-tests (Quality Assurance)

Ensures comprehensive testing:

- RSpec/Minitest setup
- Model/controller/request specs
- System tests
- FactoryBot factories
- Test coverage reporting

**Best for:**

- Setting up testing
- Writing test coverage
- Testing strategies
- CI/CD integration

### rails-devops (Deployment)

Manages infrastructure:

- Docker configuration
- Kamal deployment
- CI/CD pipelines
- Environment management
- Monitoring and logging
- Database backups

**Best for:**

- Deployment setup
- Docker configuration
- CI/CD pipelines
- Production optimization

## Usage Examples

### Example 1: Complete Blog Feature

```
You: /rails-feature Blog with posts, comments, and tags

Architect analyzes and coordinates:
1. rails-models: Creates Post, Comment, Tag models with associations
2. rails-controllers: Generates posts, comments controllers
3. rails-views: Builds index/show/form views with Turbo
4. rails-tests: Adds comprehensive test coverage

Result: Complete, tested blog feature ready to use
```

### Example 2: Refactor Fat Controller

```
You: /rails-refactor The orders controller has too much logic

Architect coordinates:
1. Reads app/controllers/orders_controller.rb
2. rails-services: Creates OrderProcessor service object
3. rails-controllers: Slims down controller to use service
4. rails-tests: Adds service and controller specs

Result: Clean, maintainable code following Rails patterns
```

### Example 3: Add Real-time Features

```
You: /rails-dev Add real-time notifications using Turbo Streams

Architect implements:
1. rails-models: Notification model with associations
2. rails-controllers: Notifications controller with turbo_stream format
3. rails-views: Turbo Frame/Stream templates
4. rails-tests: System tests with JavaScript driver

Result: Working real-time notifications
```

### Example 4: API Development

```
You: /rails-feature API endpoints for products

Architect creates:
1. rails-models: Product model (if needed)
2. rails-controllers: Api::V1::ProductsController with JSON responses
3. rails-tests: Comprehensive request specs

Result: Versioned API with proper serialization
```

## Key Differences from claude-on-rails

| Feature | claude-on-rails | rails-dev-workflow |
|---------|----------------|-------------------|
| **Architecture** | Gem with claude-swarm | Claude Code plugin |
| **Agent System** | claude-swarm coordination | Native Claude Code Task tool |
| **Installation** | gem install + CLAUDE.md | Copy plugin files |
| **Dependencies** | claude-swarm gem | None (native) |
| **Configuration** | .claude-on-rails/ directory | Built into plugin |
| **Agent Types** | 7 agents with custom prompts | 7 agents with similar roles |
| **Invocation** | Natural language | Slash commands + natural language |
| **MCP Integration** | Rails MCP server | Can be added separately |

## Best Practices

### 1. Start with the Right Command

- Use `/rails-dev` for general requests
- Use `/rails-feature` for complete features
- Use `/rails-refactor` for code improvements

### 2. Be Specific

Good: "Create a Post model with title, body, and user association"
Better: "Create a blog Post model with title (string, 255 chars), body (text), published (boolean), belongs to User, has many Comments"

### 3. Trust the Architect

The architect agent understands Rails conventions and will make good decisions about:

- Database design
- RESTful routing
- Association configurations
- When to extract service objects

### 4. Iterate

You can refine features after initial generation:

```
1. /rails-feature User authentication
2. Review the implementation
3. /rails-refactor Add two-factor authentication
4. /rails-dev Add password complexity requirements
```

### 5. Let Agents Work in Parallel

The architect will run independent tasks in parallel for faster development.

## Rails Conventions Followed

This plugin enforces Rails best practices:

- **RESTful Design**: Standard REST actions and routing
- **Thin Controllers**: Business logic in models or services
- **Strong Parameters**: Mass assignment protection
- **Convention over Configuration**: Rails naming conventions
- **Testing**: Comprehensive test coverage
- **Modern Rails**: Turbo, Stimulus, Hotwire patterns
- **Security**: Authentication, authorization, XSS protection
- **Performance**: Eager loading, caching, indexes

## Requirements

- **Ruby**: 3.0+
- **Rails**: 7.0+
- **Claude Code**: Latest version
- **Project**: Must be a Rails application

## Troubleshooting

### Agents not found

Ensure agents and commands directories are in your project root or configured in Claude Code.

### Agent conflicts

If agents make conflicting changes, the architect will resolve them. You can also manually review and adjust.

### Missing dependencies

Some features require specific gems (Devise, Pundit, etc.). The agents will recommend installations.

## Contributing

Contributions are welcome! To improve this plugin:

1. Enhance agent prompts for better coordination
2. Add new specialized agents for specific domains
3. Improve error handling and edge cases
4. Add more example scenarios

## Roadmap

Future enhancements:

- [ ] Integration with Rails MCP server for documentation
- [ ] Additional agents (rails-jobs, rails-mailers, rails-assets)
- [ ] Custom agent configuration per project
- [ ] Agent learning from project patterns
- [ ] Performance optimization agent

## License

MIT License

## Credits

Inspired by [claude-on-rails](https://github.com/obie/claude-on-rails) by Obie Fernandez.

Built for Claude Code by the Claude Squad.

## Support

For issues and questions:

- Check the [examples](./examples) directory
- Review agent prompts in the [agents](./agents) directory
- Open an issue on GitHub

## Version

0.1.0 - Initial release
