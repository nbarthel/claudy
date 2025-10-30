---
name: rails-mcp-integration
description: Integration patterns for rails-mcp-servers plugin providing documentation verification
auto_invoke: false
manual_invoke: true
tags: [rails, mcp, documentation, verification, research]
priority: 3
version: 2.0
deprecated: true
---

# Rails MCP Integration Skill

**⚠️ DEPRECATED as of v0.3.0**

This skill is deprecated in favor of the new self-contained documentation skills:
- **@rails-version-detector** - Detects Rails version from project files
- **@rails-docs-search** - Searches Rails Guides using WebFetch
- **@rails-api-lookup** - Looks up API documentation
- **@rails-pattern-finder** - Finds code patterns in codebase

**Why deprecated:**
- No external MCP server dependency required
- Faster response (no network latency)
- Works offline
- Simplified plugin installation

**Migration path:**
- Replace MCP tool calls with skill invocations
- No functional changes needed - new skills provide same capabilities
- MCP server plugin (rails-mcp-servers) still available for advanced use

---

## Original Documentation (Preserved for Reference)

Provides patterns for querying rails-mcp-servers plugin for authoritative documentation.

## What This Skill Does

**MCP Server Capabilities:**
- Query official Rails documentation
- Verify API signatures and patterns
- Check version-specific behavior
- Explore available Rails features

**When to Invoke:**
- Need current Rails documentation (manual)
- Verifying API signatures before use
- Checking version-specific features
- Exploring Rails 8+ capabilities
- Uncertain about best practices

**When NOT to Invoke:**
- Basic Rails conventions (use built-in knowledge)
- Common patterns (reference pattern library)
- Time-sensitive tasks (MCP adds latency)

## MCP Tools Available

### 1. search_rails_docs

**Purpose:** Search across all Rails documentation

**Usage:**
```
search_rails_docs("Rails 8 controller best practices")
search_rails_docs("ActiveRecord associations")
search_rails_docs("Solid Queue configuration")
```

**Returns:** List of relevant documentation sections with snippets

### 2. get_rails_guide

**Purpose:** Fetch specific guide content

**Usage:**
```
get_rails_guide("active_record_associations")
get_rails_guide("api_app")
get_rails_guide("action_cable_overview")
```

**Returns:** Full guide content in markdown

### 3. get_api_reference

**Purpose:** Get API documentation for classes/methods

**Usage:**
```
get_api_reference("ActiveRecord::Base")
get_api_reference("ActionController::API")
get_api_reference("Turbo::StreamsChannel")
```

**Returns:** API documentation with method signatures

### 4. find_rails_pattern

**Purpose:** Find recommended patterns for common tasks

**Usage:**
```
find_rails_pattern("pagination")
find_rails_pattern("authentication")
find_rails_pattern("background jobs")
```

**Returns:** Recommended implementation patterns

## Usage Patterns

### Pattern 1: Version-Specific Features

**Before implementing new Rails feature:**
```
1. Detect Rails version: Read Gemfile
2. Query MCP: search_rails_docs("Rails #{version} new features")
3. Verify availability: get_api_reference("FeatureClass")
4. Implement with confidence
```

**Example:**
```
Rails 8 detected → search_rails_docs("Rails 8 Solid Queue")
→ Confirms Solid Queue available → Use in implementation
```

### Pattern 2: API Signature Verification

**Before using unfamiliar API:**
```
1. Query MCP: get_api_reference("ActiveStorage::Blob")
2. Review method signatures
3. Check required parameters
4. Use correct API in implementation
```

**Example:**
```
get_api_reference("ActionMailer::Base")
→ Confirms .deliver_later syntax
→ Use @mailer.deliver_later (not deprecated .deliver)
```

### Pattern 3: Best Practice Lookup

**When uncertain about approach:**
```
1. Query MCP: find_rails_pattern("authentication")
2. Review recommended options (Devise, JWT, custom)
3. Query specific guide: get_rails_guide("security")
4. Implement recommended pattern
```

### Pattern 4: Project Pattern Matching

**For consistency with existing code:**
```
1. List existing files: list_directory("app/controllers")
2. Read sample: read_file("app/controllers/api/v1/base_controller.rb")
3. Query MCP for pattern: search_rails_docs("API versioning")
4. Match project conventions + Rails best practices
```

## Graceful Degradation

**When MCP servers unavailable:**
```
1. Check availability: Test MCP server connection
2. If unavailable:
   - Use built-in Rails knowledge
   - Reference pattern library (/patterns/)
   - Proceed with standard conventions
3. Log warning: MCP unavailable, using fallback
4. Continue with implementation
```

**Configuration:**
```yaml
# .rails-mcp.yml
mcp_integration:
  enabled: true
  fallback_to_web: true
  timeout_ms: 5000

verification:
  auto_verify_apis: false  # Manual invoke only
  cache_responses: true
  cache_duration: 3600  # 1 hour
```

## Integration with Agents

**Architect Usage:**
```markdown
When rails-mcp-servers available:
1. Detect Rails version via MCP
2. Verify patterns before delegating
3. Pass verified patterns to specialists
4. Ensure version-appropriate implementations
```

**Model Specialist Usage:**
```markdown
Before creating associations:
1. Query: search_rails_docs("Rails 8 associations")
2. Verify: get_api_reference("ActiveRecord::Associations")
3. Implement with current syntax
```

**Controller Specialist Usage:**
```markdown
Before implementing API endpoints:
1. Query: find_rails_pattern("RESTful API")
2. Review: get_rails_guide("api_app")
3. Match project + Rails conventions
```

## Performance Considerations

- **Network latency**: MCP queries add 100-500ms
- **Caching**: Responses cached for 1 hour
- **Selective use**: Only for uncertain cases
- **Fallback**: Always have non-MCP path

## Example Workflow

**User request:** "Build API endpoint following best practices"

**With MCP Integration:**
```
1. Invoke rails-mcp-integration skill manually
2. search_rails_docs("Rails 8 API best practices")
3. get_rails_guide("api_app")
4. Detect project patterns (API::V1 namespace)
5. Combine MCP docs + project conventions
6. Generate API controller with verified patterns
```

**Without MCP:**
```
1. Use built-in Rails knowledge
2. Follow standard RESTful conventions
3. Match existing project patterns
4. Generate API controller
```

## References

- **Rails MCP Servers Plugin**: plugins/claudy/rails-mcp-servers/
- **MCP Protocol**: https://modelcontextprotocol.io/
- **Pattern Library**: /patterns/api-patterns.md

---

**This skill provides authoritative, version-accurate Rails documentation when you need it most.**
