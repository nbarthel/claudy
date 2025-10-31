# Claudy: AI Coding Agent Instructions

This guide enables AI agents to be immediately productive in the Claudy codebase, focusing on plugin development for Rails, React/TypeScript, code review, and UI/UX workflows.

## Architecture Overview

- **Monorepo Structure:** All plugins live under `plugins/claudy/`, grouped by technology (e.g., `rails-generators`, `react-typescript-workflow`). Shared utilities are in `shared/`.
- **Plugin Boundaries:** Each plugin is self-contained with its own `package.json`, `README.md`, and command/agent definitions. No cross-plugin imports.
- **Service Integration:** Rails plugins use built-in skills with Ref MCP for token-efficient documentation queries.

## Developer Workflows

- **Install Plugins:** Use `/plugin install <plugin>@claudy` in Claude Code CLI, or run provided shell scripts in `scripts/`.
- **Rails Plugin Usage:**
  - Copy `.claude` or `.claude-plugin` directories to your Rails project root for agent activation.
  - Use slash commands (e.g., `/rails-generate-model`, `/rails-add-turbo-stream`) to automate Rails tasks.
- **Documentation Skills:**
  - Built-in skills (rails-docs-search, rails-api-lookup, rails-pattern-finder) provide agents with access to Rails documentation.
  - Agents query Rails docs for conventions, reducing hallucination and ensuring up-to-date patterns.
  - Optional ref-tools-mcp server can be installed for token-efficient documentation access.

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

- **External Docs:** Rails plugins fetch official Rails documentation via built-in skills using Ref MCP or WebFetch.

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

- `plugins/<plugin>/README.md` — Plugin-specific usage and conventions
- `plugins/rails-workflow/skills/` — Built-in documentation skills (Ref MCP integration)
- `scripts/` — Shell scripts for plugin management

---

For unclear or incomplete sections, please provide feedback to improve these instructions.
