# Rails MCP Servers - Example Usage

Examples showing how MCP servers enhance Rails development with Claude Code.

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [Documentation Access](#documentation-access)
3. [Filesystem Operations](#filesystem-operations)
4. [Integration with Agents](#integration-with-agents)

---

## Basic Setup

### Installing MCP Servers

```bash
# In your Rails project
claude

# Install the MCP servers plugin
/plugin install rails-mcp-servers@claudy

# Verify installation
/plugin list
```

### Verifying MCP Server Status

After installation, Claude Code will automatically start the configured MCP servers. You can verify they're running:

```
You: "Can you access Rails documentation?"

Claude: "Yes, I have access to the Rails documentation server which provides:
- Rails Guides (7.1)
- API Documentation
- Turbo/Stimulus docs
- Hotwire patterns
- Kamal deployment docs

What would you like to know about Rails?"
```

---

## Documentation Access

### Example 1: Checking Current Rails Patterns

**Without MCP Servers:**

```
You: "What's the current syntax for has_many with counter cache?"

Claude: "Based on my training, you can use:
has_many :posts, counter_cache: true
"
# May be outdated or incorrect for your Rails version
```

**With MCP Servers:**

```
You: "What's the current syntax for has_many with counter cache in Rails 7.1?"

Claude: [Queries rails-docs MCP server]
"According to the Rails 7.1 documentation, the correct syntax is:

class User < ApplicationRecord
  has_many :posts, dependent: :destroy
end

class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

The counter_cache should be on the belongs_to side. You'll also need a migration to add the counter cache column:

add_column :users, :posts_count, :integer, default: 0, null: false
"
# Verified against current docs
```

### Example 2: Turbo Streams Best Practices

**Without MCP Servers:**

```
You: "How do I broadcast Turbo Stream updates?"

Claude: [Provides general answer based on training data]
```

**With MCP Servers:**

```
You: "How do I broadcast Turbo Stream updates in Rails 7.1?"

Claude: [Accesses Turbo documentation via MCP]
"According to the current Turbo documentation, there are several methods:

1. **After Callbacks:**
   class Message < ApplicationRecord
     after_create_commit -> { broadcast_prepend_to 'messages' }
   end

2. **Manual Broadcasting:**
   Turbo::StreamsChannel.broadcast_update_to(
     'messages',
     target: 'message_1',
     partial: 'messages/message',
     locals: { message: @message }
   )

3. **In Controllers:**
   respond_to do |format|
     format.turbo_stream
     format.html { redirect_to @message }
   end

For Rails 7.1, the recommended approach is using the after_*_commit callbacks for automatic broadcasting."
```

### Example 3: Migration Best Practices

```
You: "Should I use change or up/down in my migration?"

Claude: [Queries Rails migration documentation]
"According to Rails 7.1 migration guide:

Use `change` when Rails can automatically reverse your migration:
- add_column
- create_table
- add_index
- add_reference

class AddEmailToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :email, :string
  end
end

Use `up/down` when Rails cannot automatically reverse:
- remove_column (unless you specify the type)
- execute (SQL)
- Custom data transformations

class RemoveDeprecatedField < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :old_field
  end

  def down
    add_column :users, :old_field, :string
  end
end

Rails can auto-reverse most common operations, so prefer `change` for simplicity."
```

---

## Filesystem Operations

### Example 4: Reading Existing Patterns

**Scenario:** Creating a new model that should match existing project patterns

```
You: "Create a Comment model with validations"

Claude: [Uses filesystem MCP to read existing models]
"I notice your project uses specific validation patterns. Let me match them:

[Reads app/models/post.rb via filesystem MCP]

I see you use:
- validates presence with specific messages
- Custom validation methods
- Scopes with specific naming

Creating Comment model matching your patterns:

class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user

  validates :body, presence: { message: 'cannot be blank' }
  validates :body, length: {
    minimum: 1,
    maximum: 1000,
    message: 'must be between 1 and 1000 characters'
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }

  def truncated_body
    body.truncate(100)
  end
end

This matches the style of your Post model."
```

### Example 5: Analyzing Project Structure

```
You: "Where should I put my service objects?"

Claude: [Lists directories via filesystem MCP]
"Looking at your project structure:

app/
├── controllers/
├── models/
├── services/     ← You already have this
├── views/
└── ...

You already have an app/services/ directory. Let me check the pattern:

[Reads app/services/posts/publish_service.rb]

I see you organize services by domain (posts/, users/, etc.) and use a Result object pattern.

I'll place the new service in:
app/services/comments/moderate_service.rb

Following your existing pattern..."
```

### Example 6: Consistent Test Patterns

```
You: "Write tests for the Comment model"

Claude: [Reads existing test files via filesystem MCP]
"I'll match your existing test patterns.

[Reads spec/models/post_spec.rb]

I see you:
- Use FactoryBot with traits
- Group tests by concern
- Use shoulda-matchers
- Have specific let blocks for setup

Creating spec/models/comment_spec.rb:

require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:comment) { create(:comment, post: post, user: user) }

  describe 'validations' do
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:body).is_at_most(1000) }
  end

  describe 'associations' do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

  # ... matching your pattern
end

This follows the same structure as your Post model specs."
```

---

## Integration with Agents

### Example 7: Rails Architect Using MCP

When you have both `rails-mcp-servers` and `rails-dev-workflow` installed:

```
You: /rails-feature Blog with posts and comments

Rails Architect Agent:
1. [Accesses Rails docs via MCP] Checks Rails 7.1 association patterns
2. [Reads existing models via filesystem] Matches your project's style
3. Delegates to rails-models agent
   → Creates Post model following your conventions
   → Creates Comment model with verified associations
4. Delegates to rails-controllers agent
   → Implements controllers with Turbo Stream (verified via docs)
5. Delegates to rails-views agent
   → Uses current Turbo Frame syntax from docs
6. Delegates to rails-tests agent
   → Matches your existing test patterns

Result: Complete feature following current Rails 7.1 patterns and your project conventions
```

### Example 8: Documentation-Driven Refactoring

```
You: /rails-refactor Extract publication logic to service

Rails Services Agent:
1. [Checks Rails service object patterns in docs]
2. [Reads your existing services via filesystem]
3. Creates service matching both:
   - Current Rails patterns
   - Your project's service pattern

class Posts::PublishService
  # Follows your Result object pattern (from reading existing services)
  # Uses Rails 7.1 transaction syntax (from docs)
  # Matches your naming conventions (from filesystem analysis)
end
```

### Example 9: Error-Free Code Generation

**Without MCP Servers:**

```
You: "Add Turbo Stream support"

Agent: [May use outdated syntax]
turbo_stream.replace "post_#{@post.id}", @post
# Might be old syntax
```

**With MCP Servers:**

```
You: "Add Turbo Stream support"

Agent: [Verifies current syntax in Turbo docs]
<%= turbo_stream.replace dom_id(@post) do %>
  <%= render @post %>
<% end %>
# Current Rails 7.1 + Turbo 7.x syntax
```

---

## Advanced Scenarios

### Example 10: Multi-File Refactoring

```
You: "Refactor authentication to use a concern"

Claude:
1. [Reads all controllers via filesystem MCP]
   - Identifies common authentication patterns
   - Finds repeated before_actions

2. [Checks Rails concerns documentation]
   - Verifies current concern syntax
   - Checks best practices

3. Creates concern matching:
   - Your naming conventions (from reading files)
   - Current Rails patterns (from docs)
   - Your project structure (from filesystem analysis)

4. Updates all controllers:
   - Replaces repeated code with concern
   - Maintains your code style
   - Uses current Rails syntax
```

### Example 11: Version-Specific Features

```
You: "Can I use async queries in this Rails app?"

Claude: [Checks Rails version in docs and project]
"I see you're using Rails 7.1. Let me check the documentation...

Yes! Rails 7.1 supports async queries. According to the Active Record guide:

users = User.where(active: true).async_load

This loads the query in the background. However, I notice you're using SQLite in development (from reading config/database.yml). Async queries work better with PostgreSQL.

Would you like me to:
1. Implement async queries for production (PostgreSQL)
2. Add a check to only use async in production
3. Show you the performance benefits?"
```

---

## Troubleshooting with MCP

### Example 12: Debugging MCP Access

```
You: "Test if MCP servers are working"

Claude: "Let me verify MCP server access:

1. Rails Documentation Server:
   [Attempts to fetch Rails guide]
   ✓ Successfully accessed Rails 7.1 guides
   ✓ Can search API documentation

2. Filesystem Server:
   [Attempts to list app/ directory]
   ✓ Can read app/models
   ✓ Can read app/controllers
   ✓ Access to app/, config/, db/, spec/

Both MCP servers are functioning correctly!"
```

---

## Summary

MCP servers enhance Rails development by:

1. **Verification**: Agents verify patterns against current documentation
2. **Consistency**: Filesystem access ensures project pattern matching
3. **Accuracy**: Current syntax and methods for your Rails version
4. **Intelligence**: Understanding of both framework and project conventions

Install both plugins for best results:

```bash
/plugin install rails-mcp-servers@claudy
/plugin install rails-api-workflow@claudy
```

This gives you documentation access + specialized agents that use that documentation!
