# Rails MCP Servers Plugin

MCP (Model Context Protocol) server configurations for Rails development, providing AI agents with access to Rails documentation, filesystem operations, and Rails-specific tooling.

## Overview

Foundation infrastructure for Rails development in Claude Code. This plugin provides MCP servers that give AI agents enhanced capabilities:

- **rails-docs**: Access to official Rails 8 documentation, guides, and API references
- **filesystem**: Safe, scoped filesystem operations for Rails project structure

**Works Standalone or with Workflow Plugins:**

- ✅ Use independently for general Rails assistance
- ✅ Enhances `rails-api-workflow` agents
- ✅ Improves `rails-generators` accuracy
- ✅ Helps `rails-code-reviewer` verify patterns
- ✅ Can be used by any Rails plugin

## What are MCP Servers?

MCP (Model Context Protocol) servers provide AI agents with access to external resources and tools. For Rails development, this means:

1. **Reduced Hallucination**: Agents can verify patterns against official Rails documentation
2. **Current Information**: Access to up-to-date Rails guides and API docs
3. **Safe File Operations**: Scoped filesystem access to Rails project directories
4. **Framework Awareness**: Understanding of Rails conventions and patterns

## Installation

### Via Claude Code (Recommended)

```bash
# In your Rails project directory
claude

# Install the plugin
/plugin install rails-mcp-servers@claudy
```

### Manual Installation

```bash
# Copy to your Rails project
cp -r path/to/claudy/plugins/claudy/rails-mcp-servers/.claude-plugin <your-rails-project>/
cp -r path/to/claudy/plugins/claudy/rails-mcp-servers/mcp-servers <your-rails-project>/
```

## MCP Servers Included

### 1. Rails Documentation Server

**Purpose**: Provides access to official Rails documentation

**Capabilities:**

- Search Rails guides
- Get API documentation
- Find Rails patterns and best practices
- Access Turbo, Stimulus, and Hotwire docs
- Kamal deployment documentation

**Resources Available:**

- Rails Guides (Getting Started, Active Record, etc.)
- API Documentation (full Rails API)
- Active Record docs
- Action Controller docs
- Action View docs
- Turbo documentation
- Stimulus documentation
- Hotwire patterns
- Kamal deployment docs

**Tools Provided:**

- `search_rails_docs` - Search across all documentation
- `get_rails_guide` - Fetch specific guide content
- `get_api_reference` - Get API documentation for classes/methods
- `find_rails_pattern` - Find recommended patterns for common tasks

**Example Usage:**

```
Agent can now query: "What's the Rails convention for naming controllers?"
Instead of hallucinating, it fetches: Rails naming conventions guide
```

### 2. Filesystem Server

**Purpose**: Safe filesystem operations scoped to Rails project

**Capabilities:**

- Read files in Rails directories
- Write new files (migrations, models, controllers, etc.)
- List directory contents
- Search for files
- Get file metadata

**Allowed Directories:**

- `app/` - Application code
- `config/` - Configuration
- `db/` - Database schemas and migrations
- `lib/` - Libraries and custom code
- `spec/` - RSpec tests
- `test/` - Minitest tests

**Restricted Directories (for safety):**

- `node_modules/` - Not accessible
- `tmp/` - Not accessible
- `log/` - Not accessible
- `.git/` - Not accessible

**Tools Provided:**

- `read_file` - Read file contents
- `write_file` - Create or update files
- `list_directory` - List directory contents
- `search_files` - Search for files by pattern
- `get_file_info` - Get file metadata (size, modified date, etc.)

## How Agents Use MCP Servers

When you install this plugin, the Rails development agents (from `rails-dev-workflow` plugin) automatically gain access to these capabilities:

### Without MCP Servers

```
You: "Generate a Post model with associations"
Agent: Creates model based on general Rails knowledge (may not be current)
```

### With MCP Servers

```
You: "Generate a Post model with associations"
Agent:
1. Checks current Rails 7.1 documentation for model patterns
2. Verifies association syntax against official docs
3. Uses filesystem server to read existing models for consistency
4. Generates model following current Rails conventions
5. Creates migration following Rails 7.1 patterns
```

## Benefits

### 1. Accurate Rails Patterns

Agents verify their implementations against official documentation:

- Current syntax and methods
- Deprecated feature warnings
- Best practices
- Security considerations

### 2. Consistent Code Style

Agents can read existing project files to match:

- Naming conventions
- Code organization
- Test patterns
- Configuration styles

### 3. Framework Version Awareness

Documentation is version-specific:

- Rails 7.1 features
- Turbo 7.x patterns
- Stimulus 3.x conventions
- Current Hotwire best practices

### 4. Reduced Errors

By checking documentation:

- Correct method signatures
- Valid options and parameters
- Proper syntax
- Working examples

## Configuration

### Rails Version

Set the Rails version in your project's MCP configuration:

```json
{
  "env": {
    "RAILS_VERSION": "7.1"
  }
}
```

Supported versions: 7.0, 7.1, edge

### Filesystem Scope

The filesystem server is automatically scoped to your Rails project root. You can further restrict directories by modifying `mcp-servers/filesystem.json`:

```json
{
  "env": {
    "ALLOWED_DIRECTORIES": "app,config,db,spec"
  }
}
```

## Security

### Filesystem Security

- **Scoped Access**: Only Rails project directories are accessible
- **No System Access**: Cannot access files outside project
- **Restricted Paths**: Critical directories like `.git`, `node_modules` are blocked
- **Read/Write Control**: Agents can only perform safe file operations

### Documentation Security

- **Read-Only**: Documentation server is read-only
- **No Execution**: Cannot execute code, only read docs
- **Official Sources**: Only fetches from official Rails documentation

## Works with Rails Plugins

This infrastructure plugin enhances multiple Rails plugins:

### rails-api-workflow (Highly Recommended)

Multi-agent Rails 8 API development workflow:

```bash
/plugin install rails-api-workflow@claudy
```

**Enhanced capabilities when both installed:**

- rails-architect: Verifies patterns before delegating
- rails-models: Matches existing model patterns
- rails-controllers: Uses current Rails 8 controller conventions
- rails-services: Verifies Solid Queue and job patterns
- rails-tests: Matches existing test structure

### rails-generators

Rails code generation commands:

```bash
/plugin install rails-generators@claudy
```

**With MCP servers:** Generators verify syntax against Rails 8 docs

### rails-code-reviewer

Rails code review agent:

```bash
/plugin install rails-code-reviewer@claudy
```

**With MCP servers:** Reviewer verifies recommendations against official docs

**All plugins work independently** - MCP servers are an enhancement, not a requirement.

## Troubleshooting

### MCP Server Not Starting

1. **Check Dependencies**:

   ```bash
   npm install -g @modelcontextprotocol/server-rails
   npm install -g @modelcontextprotocol/server-filesystem
   ```

2. **Verify Configuration**: Ensure `mcp-servers/*.json` files are valid JSON

3. **Check Logs**: Look for MCP server errors in Claude Code logs

### Documentation Not Loading

1. **Network Connection**: Ensure you have internet access for docs
2. **Rails Version**: Verify `RAILS_VERSION` is set correctly
3. **Server Status**: Check if rails-docs server is running

### Filesystem Access Denied

1. **Project Root**: Ensure MCP server is run from Rails project root
2. **Permissions**: Check file/directory permissions
3. **Allowed Directories**: Verify path is in allowed directories list

## Examples

### Example 1: Model Generation with Docs

```
You: Create a Post model with validations

Agent process:
1. Queries rails-docs for current model validation syntax
2. Reads existing models via filesystem server
3. Generates model matching project patterns
4. Verifies against Rails 7.1 documentation
5. Creates properly formatted model file
```

### Example 2: Migration Best Practices

```
You: Add an index to posts table

Agent process:
1. Checks Rails migration documentation for index syntax
2. Reads existing migrations for naming patterns
3. Generates migration with proper syntax
4. Includes reversibility (down method)
5. Follows Rails migration conventions
```

### Example 3: Turbo Stream Implementation

```
You: Add Turbo Stream support for comments

Agent process:
1. Fetches current Turbo documentation
2. Reads existing Turbo usage in project
3. Implements matching patterns
4. Uses current Turbo 7.x syntax
5. Follows Hotwire conventions
```

## Advanced Usage

### Custom Documentation Sources

You can extend the rails-docs server to include additional documentation:

```json
{
  "capabilities": {
    "resources": [
      "rails-guides",
      "custom-company-docs",
      "internal-rails-patterns"
    ]
  }
}
```

### Project-Specific Filesystem Rules

Add project-specific rules in `filesystem.json`:

```json
{
  "env": {
    "ALLOWED_DIRECTORIES": "app,config,db,spec,lib/custom",
    "CUSTOM_RULES": "allow:lib/custom,deny:lib/vendor"
  }
}
```

## Requirements

- **Node.js**: 18+ (for MCP servers)
- **NPM Packages**:
  - `@modelcontextprotocol/server-rails`
  - `@modelcontextprotocol/server-filesystem`
- **Rails**: 7.0+
- **Claude Code**: Latest version

## Installation of Dependencies

The MCP servers require Node.js packages:

```bash
# Install globally (recommended)
npm install -g @modelcontextprotocol/server-rails
npm install -g @modelcontextprotocol/server-filesystem

# Or locally in your project
npm install --save-dev @modelcontextprotocol/server-rails
npm install --save-dev @modelcontextprotocol/server-filesystem
```

## Versioning

- **Plugin Version**: 0.1.0
- **MCP Protocol**: v1.0
- **Rails Compatibility**: 7.0, 7.1, edge

## Contributing

Improvements welcome:

- Additional MCP servers for Rails tools
- Enhanced documentation coverage
- Better filesystem scoping rules
- Integration with more Rails tools

## License

MIT License

## Credits

- Built for Claude Code by Claude Squad
- Uses MCP (Model Context Protocol) servers
- Rails documentation from official Rails guides
- Inspired by [claude-on-rails](https://github.com/obie/claude-on-rails) MCP integration

## Related Resources

- [Rails Dev Workflow Plugin](../rails-dev-workflow/README.md) - Complementary workflow plugin
- [MCP Documentation](https://github.com/modelcontextprotocol/servers) - Official MCP server docs
- [Rails Guides](https://guides.rubyonrails.org) - Official Rails documentation

## Version

0.1.0 - Initial release

## Support

For issues:

- Check MCP server logs
- Verify NPM package installation
- Review configuration files
- Open GitHub issue if problems persist
