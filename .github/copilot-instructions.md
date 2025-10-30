# Claudy: AI Coding Agent Instructions

This guide enables AI agents to be immediately productive in the Claudy codebase, focusing on plugin development for Rails, React/TypeScript, code review, and UI/UX workflows.

## Architecture Overview

- **Monorepo Structure:** All plugins live under `plugins/claudy/`, grouped by technology (e.g., `rails-generators`, `react-typescript-workflow`). Shared utilities are in `shared/`.
- **Plugin Boundaries:** Each plugin is self-contained with its own `package.json`, `README.md`, and command/agent definitions. No cross-plugin imports.
- **Service Integration:** Rails plugins use MCP servers (`rails-mcp-servers`) for safe filesystem access and real-time Rails documentation queries.

## Developer Workflows

- **Install Plugins:** Use `/plugin install <plugin>@claudy` in Claude Code CLI, or run provided shell scripts in `scripts/`.
- **Rails Plugin Usage:**
  - Copy `.claude` or `.claude-plugin` directories to your Rails project root for agent activation.
  - Use slash commands (e.g., `/rails-generate-model`, `/rails-add-turbo-stream`) to automate Rails tasks.
- **MCP Servers:**
  - MCP servers (see `rails-mcp-servers/mcp-servers/`) provide agents with scoped access to Rails docs and project files. Configuration is in JSON files; only allowed directories are accessible.
  - Agents query Rails docs for conventions, reducing hallucination and ensuring up-to-date patterns.

## Project-Specific Conventions

- **Rails:**
  - Always follow Rails 7.0+ conventions (model, migration, controller, Turbo/Hotwire patterns).
  - Service objects use clear structure and explicit success/failure returns.
  - Tests are generated for new models/controllers (RSpec or Minitest, depending on project setup).
- **React/TypeScript:**
  - Components and hooks are generated with TypeScript types and React best practices.
  - Context/state management uses React Context API and React Query for data fetching.
- **Documentation:**
  - Each plugin must update its own `README.md` and document new commands/agents.

## Integration Points

- **External Docs:** Rails plugins fetch official Rails, Turbo, Stimulus, and Kamal docs via MCP servers.
- **Filesystem Access:** Agents can only read/write within allowed directories (`app/`, `config/`, `db/`, etc.). Critical directories (`.git/`, `node_modules/`, etc.) are blocked.

## Examples

- To generate a Rails model:

  ```
  /rails-generate-model
  # Agent will prompt for name/fields, generate model, migration, tests, and update docs.
  ```

- To add Turbo Stream to a controller:

  ```
  /rails-add-turbo-stream for the create action in PostsController
  # Agent generates Turbo Stream views and updates controller.
  ```

## Key Files & Directories

- `plugins/claudy/<plugin>/README.md` — Plugin-specific usage and conventions
- `plugins/claudy/rails-mcp-servers/mcp-servers/` — MCP server configs
- `shared/utils/` — Common utilities for plugin builders
- `scripts/` — Shell scripts for plugin management

---

For unclear or incomplete sections, please provide feedback to improve these instructions.
