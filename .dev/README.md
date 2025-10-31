# Development Documentation

This directory contains historical development documentation and session notes.

**Note**: Some documents reference the deprecated `rails-mcp-servers` plugin which has been replaced by built-in skills in rails-workflow v0.3.0.

## Current Architecture (v0.3.0+)

- Rails documentation is accessed via built-in skills (rails-docs-search, rails-api-lookup, rails-pattern-finder)
- Skills use Ref MCP (primary) with WebFetch fallback
- No separate MCP server plugin required

## Historical Documents

Files in this directory represent the evolution of the project and may reference deprecated approaches.
