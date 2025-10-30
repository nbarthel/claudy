---
name: rails-conventions
description: Automatically enforces Rails naming conventions, MVC separation, and RESTful patterns
auto_invoke: true
trigger_on: [file_create, file_modify]
file_patterns: ["*.rb", "*.erb", "config/routes.rb"]
tags: [rails, conventions, patterns, rest, mvc]
priority: 1
version: 2.0
---

# Rails Conventions Skill

Auto-validates and enforces Rails conventions across all code changes.

## What This Skill Does

**Automatic Enforcement:**
- Model naming: PascalCase, singular (User, not Users)
- Controller naming: PascalCase, plural, ends with Controller (UsersController)
- File paths: snake_case matching class names (users_controller.rb)
- RESTful routes: Standard 7 actions (index, show, new, create, edit, update, destroy)
- MVC separation: No business logic in views, no SQL in controllers

**When It Activates:**
- Every time a .rb file is created or modified
- When routes.rb is changed
- When view files are created

**What It Checks:**

1. **Naming Conventions**
   - Class names follow Rails conventions
   - File names match class names (snake_case ↔ PascalCase)
   - Variable names descriptive and snake_case
   - Constants in SCREAMING_SNAKE_CASE

2. **MVC Separation**
   - Controllers: Thin, delegate to models/services
   - Models: Business logic, no rendering
   - Views: Presentation only, minimal logic

3. **RESTful Patterns**
   - Routes follow REST conventions
   - Custom actions documented and justified
   - Nested routes limited to 2 levels

4. **Rails Idioms**
   - Use scopes over class methods for queries
   - Use concerns for shared behavior
   - Use before_action for controller filters

## Validation Examples

### Example 1: Model Naming

**Input:**
```ruby
# app/models/users.rb
class Users < ApplicationRecord
end
```

**Skill Output:**
```
❌ Convention Violation: Model class name should be singular
Expected: User
Found: Users

Fix:
- Rename class to "User"
- Rename file to "user.rb"
```

### Example 2: Controller Naming

**Input:**
```ruby
# app/controllers/user.rb
class User < ApplicationController
end
```

**Skill Output:**
```
❌ Convention Violation: Controller class name should be plural and end with 'Controller'
Expected: UsersController
Found: User

❌ File Naming: Controller file should match class name
Expected: users_controller.rb
Found: user.rb
```

### Example 3: MVC Separation

**Input:**
```ruby
# app/controllers/posts_controller.rb
def index
  @posts = Post.where("created_at > ?", 1.week.ago)
              .joins(:author)
              .order(created_at: :desc)
end
```

**Skill Output:**
```
⚠️  MVC Separation: Complex query logic in controller
Recommendation: Extract to model scope

Suggested refactoring:
# app/models/post.rb
scope :recent, -> { where("created_at > ?", 1.week.ago) }
scope :with_author, -> { joins(:author) }
scope :newest_first, -> { order(created_at: :desc) }

# app/controllers/posts_controller.rb
def index
  @posts = Post.recent.with_author.newest_first
end
```

### Example 4: RESTful Routes

**Input:**
```ruby
# config/routes.rb
resources :posts do
  get 'activate'
  get 'deactivate'
  get 'toggle_status'
  get 'publish'
end
```

**Skill Output:**
```
⚠️  RESTful Pattern: Multiple custom actions detected
Current: 4 custom actions (activate, deactivate, toggle_status, publish)
Recommendation: Consider consolidating to single update action

Suggested refactoring:
resources :posts do
  patch 'status', to: 'posts#update_status'
end

# Controller:
def update_status
  action = params[:action_type] # 'activate', 'deactivate', 'publish'
  @post.update!(status: action)
end
```

## Configuration

Skill can be configured via `.rails-conventions.yml`:

```yaml
# .rails-conventions.yml
naming:
  enforce_singular_models: true
  enforce_plural_controllers: true

mvc_separation:
  max_controller_lines: 100
  warn_on_complex_queries: true

restful:
  max_custom_actions: 2
  max_nesting_depth: 2
```

## Auto-Fix Capability

This skill can automatically fix simple violations:

**Auto-fixable:**
- File renaming to match class names
- Converting class method queries to scopes
- Extracting inline queries to model scopes

**Manual fix required:**
- Class name changes (impacts migrations, associations)
- MVC layer violations (requires architectural decisions)
- Custom route consolidation (business logic dependent)

## Integration with Agents

This skill enhances all agents:

- **@rails-model-specialist**: Validates model naming and scope usage
- **@rails-controller-specialist**: Enforces RESTful patterns and thin controllers
- **@rails-view-specialist**: Validates view logic separation
- **@rails-architect**: Provides convention checks during coordination

## Severity Levels

- **❌ Error**: Blocks commit (via pre-commit hook) - naming violations, missing strong params
- **⚠️  Warning**: Suggests improvement - complex queries, non-RESTful routes
- **ℹ️  Info**: Best practice suggestion - use of concerns, scope opportunities

## Performance

- Activates on: File save
- Execution time: < 100ms per file
- No network calls
- Works offline

---

**This skill runs automatically - no invocation needed. It keeps your Rails code conventional and maintainable.**
