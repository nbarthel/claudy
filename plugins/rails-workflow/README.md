# Rails Workflow Plugin v0.3.0

A comprehensive, self-contained Rails development plugin inspired by [claude-on-rails](https://github.com/obie/claude-on-rails) that orchestrates specialized AI agents to build full-stack Rails features. Unlike claude-on-rails which uses the claude-swarm gem, this plugin uses native Claude Code agent capabilities.

## Version 0.3.0 - Self-Contained Edition ✨

**What's New in v0.3.0:**
- 🚀 **Self-Contained Documentation** - No external MCP server dependency required
- 📚 **4 New Documentation Skills** - Version detection, docs search, API lookup, pattern finding
- ⚡ **Faster Response Times** - Built-in skills eliminate network latency
- 🔌 **Simplified Installation** - Works immediately without MCP server setup
- 📖 **Offline Capable** - Documentation skills work without internet (using WebFetch)

**Previous Features (v2.0):**
- ✨ **6 Auto-Invoking Skills** - Automatic quality enforcement (conventions, security, performance, testing)
- 🔒 **3 Quality Gate Hooks** - Block bad code before it reaches git (pre-agent, post-agent, pre-commit)
- 🎯 **Enhanced Architect Agent** - 7 comprehensive examples, tool mastery patterns, success criteria
- 📚 **Best Practices Built-In** - Rails conventions, security patterns, performance optimization
- 🚀 **Zero Configuration** - Skills and hooks activate automatically

## Overview

This plugin provides a team of specialized Rails agents that work together like a real development team, **with automatic quality enforcement** through skills and hooks.

**Self-Contained Design** (v0.3.0): All documentation capabilities are now built-in as skills - no external MCP server required! The plugin includes:
- Rails version detection from project files
- Official Rails Guides search via WebFetch
- API documentation lookup
- Code pattern finding in your codebase

**Optional Enhancement**: The separate `rails-mcp-servers` plugin is still available for advanced use cases, but is no longer required for basic functionality.

## Documentation Skills (v0.3.0) 📚

**New in v0.3.0**: Self-contained skills for Rails documentation lookup - no MCP server required!

### 4 Documentation Skills

| Skill | Auto-invoke | Purpose | Speed |
|-------|------------|---------|-------|
| **rails-version-detector** | ✅ Auto | Detects Rails version from Gemfile.lock/Gemfile | < 1s |
| **rails-docs-search** | 🔍 On-demand | Searches Rails Guides for concepts | 2-5s |
| **rails-api-lookup** | 🔍 On-demand | Looks up specific API signatures | 2-5s |
| **rails-pattern-finder** | 🔍 On-demand | Finds code patterns in project | 1-3s |

**How They Work:**

```
Agent needs Rails info → Auto-detects version → Fetches relevant docs → Uses correct syntax

Example:
1. Agent creating model
2. Invokes @rails-version-detector → Rails 7.1.3
3. Invokes @rails-api-lookup class="ActiveRecord::Base"
4. Gets version-specific API → Uses correct syntax
```

**Key Benefits:**
- 🚀 **No setup required** - Works immediately after plugin install
- ⚡ **Fast** - Version detection < 1s, docs fetch 2-5s
- 📖 **Accurate** - Fetches from official Rails docs (guides.rubyonrails.org, api.rubyonrails.org)
- 🔌 **Smart fetching** - Uses Ref (primary) for token efficiency, WebFetch (fallback) built-in
- 🎯 **Version-aware** - Always uses docs matching your Rails version
- 💡 **Optional enhancement** - Install ref-tools-mcp for even better performance

See [Documentation Skills Guide](#documentation-skills-guide) below for detailed usage.

## Quality Skills (v2.0) ✨

Skills automatically validate and improve code quality **without explicit invocation**. They run in the background, catching issues before they become problems.

### 6 Quality Skills

| Skill | Auto-invoke | Purpose | Example |
|-------|------------|---------|---------|
| **rails-conventions** | ✅ Always | Enforce naming, MVC separation, RESTful patterns | Catches plural model names, complex queries in controllers |
| **rails-security-patterns** | ✅ Always | Prevent SQL injection, validate strong parameters | Blocks string interpolation in SQL, missing params |
| **rails-performance-patterns** | ✅ Always | Detect N+1 queries, suggest indexes | Warns about missing eager loading |
| **rails-test-patterns** | ✅ Always | Ensure AAA pattern, enforce 80%+ coverage | Validates test structure and coverage |
| **rails-mcp-integration** | ⚠️ Deprecated | Replaced by documentation skills above | Use @rails-docs-search instead |
| **agent-coordination-patterns** | ✅ Architect | Optimize multi-agent workflows | Parallel vs sequential decisions |

**How They Work:**

```
You write code → Skills validate automatically → You get instant feedback

Example:
1. Create model with plural name (Users)
2. rails-conventions skill detects: "❌ Model should be singular: User"
3. You fix it before committing
4. No bugs reach production
```

**Key Benefits:**
- 🚀 **Catches 90%+ common mistakes** automatically
- ⚡ **Instant feedback** (< 100ms per file)
- 🎯 **Zero configuration** - works out of the box
- 📚 **Educational** - explains why and how to fix

**Configuration:**

Skills can be customized via `.rails-skills.yml`:

```yaml
skills:
  rails-conventions:
    enabled: true
    severity: error  # error, warning, info

  rails-security-patterns:
    enabled: true
    block_commit: true

  rails-performance-patterns:
    enabled: true
    n1_detection: true
```

## Quality Gate Hooks (v2.0) 🔒

Hooks run at key points in the workflow to ensure code quality and security.

### 3 Hooks Included

**1. pre-agent-invoke** (5 second timeout)
- **When**: Before any agent runs
- **Checks**: Rails project structure exists (Gemfile, app/, config/)
- **Purpose**: Prevent agents from running in wrong directory
- **Result**: ✅ Pass or ❌ Block agent

**2. post-agent-invoke** (30 second timeout)
- **When**: After agent completes
- **Checks**: Security issues, Rails conventions, test results
- **Purpose**: Validate agent output quality
- **Result**: ⚠️ Warnings (doesn't block)

**3. pre-commit** (60 second timeout)
- **When**: Before git commit
- **Checks**:
  - ❌ Blocks: Secrets, debuggers, SQL injection, missing strong params
  - ⚠️ Warns: Missing tests, complex queries
- **Purpose**: Prevent bad code from reaching git
- **Result**: ✅ Allow commit or ❌ Block commit

**Example Security Blocks:**

```bash
# Trying to commit code with debugger:
$ git commit -m "Add feature"
🔒 Running pre-commit security checks...
❌ Error: Debugger statements detected
app/controllers/users_controller.rb:15:    binding.pry
Remove debugging code before committing
```

**Skip Hooks (when needed):**

```bash
# Skip all hooks temporarily
SKIP_RAILS_HOOKS=1 bundle exec rails console

# Skip git pre-commit hook
git commit --no-verify -m "WIP: debugging"
```

**Hook Configuration:**

Customize via `.rails-hooks.yml`:

```yaml
hooks:
  pre-agent-invoke:
    enabled: true
    checks: [rails_project, gemfile, app_directory]

  pre-commit:
    enabled: true
    block_on: [secrets, debuggers, sql_injection]
    warn_on: [missing_tests, style_violations]
```

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
/plugin install rails-api-workflow@claudy

# Optional: Install Ref MCP for token-efficient documentation (recommended)
# See Ref setup section below for configuration instructions

# Verify installation
/help
```

### Manual Installation

```bash
# From your Rails project root
cp -r path/to/claudy/plugins/claudy/rails-api-workflow/.claude-plugin .
cp -r path/to/claudy/plugins/claudy/rails-api-workflow/agents .
cp -r path/to/claudy/plugins/claudy/rails-api-workflow/commands .
```

### Optional: Ref MCP Setup (Recommended)

For token-efficient documentation fetching, install [ref-tools-mcp](https://github.com/ref-tools/ref-tools-mcp):

**Why install Ref?**
- 📉 **Reduced token usage** - More efficient context management
- ⚡ **Faster searches** - Optimized documentation retrieval
- 🎯 **Better results** - Smart search designed for coding agents

**Setup (choose one method):**

**Option 1: Using MCP Settings UI** (Easiest)
1. Open Claude Code settings
2. Go to MCP Servers section
3. Add ref-tools-mcp server
4. Follow the configuration wizard

**Option 2: Manual Configuration**
```json
// Add to your Claude Code MCP settings
{
  "mcpServers": {
    "ref": {
      "command": "npx",
      "args": ["-y", "@ref-tools/ref-tools-mcp"]
    }
  }
}
```

**Verification:**
```bash
# Skills will automatically use Ref if available
# Check logs for "Using ref_search_documentation" messages
```

**Note:** Skills work perfectly fine without Ref (using WebFetch fallback). Ref is purely an optional performance enhancement.

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

### rails-architect (Coordinator) - Enhanced in v2.0 ⭐

The architect analyzes your requests and coordinates other agents. **Enhanced in v2.0** with:

- **7 comprehensive examples** (simple → complex → error recovery → MCP integration)
- **Tool mastery patterns** (Read/Grep/Glob/Edit best practices documented)
- **Success criteria** (clear quality checklists before completion)
- **Clear boundaries** ("When to Use" vs "When NOT to Use")

It:
- Breaks down features into component tasks
- Determines which specialists to involve
- Sequences work when dependencies exist
- Runs agents in parallel when possible (using agent-coordination-patterns skill)
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

Built for Claude Code by Nic Barthelemy.

## Support

For issues and questions:

- Check the [examples](./examples) directory
- Review agent prompts in the [agents](./agents) directory
- Open an issue on GitHub

## Quick Start (v2.0)

```bash
# 1. Install the plugin
/plugin install rails-workflow@claudy

# 2. Optionally install MCP servers for enhanced capabilities
/plugin install rails-mcp-servers@claudy

# 3. Start building - skills and hooks activate automatically!
/rails-dev Add a Post model with title and body

# Skills auto-validate:
# ✅ Naming conventions checked
# ✅ Security patterns validated
# ✅ Performance optimized
# ✅ Tests enforced

# 4. Commit with confidence - pre-commit hook protects you
git add . && git commit -m "Add Post model"
# 🔒 Pre-commit checks: ✅ Passed
```

**That's it!** Skills and hooks work automatically. No configuration needed.

## Version

0.2.0 - Enhanced Edition (v2.0)
- Added 6 auto-invoking skills
- Added 3 quality gate hooks
- Enhanced rails-architect agent
- Built-in best practices

0.1.0 - Initial release
