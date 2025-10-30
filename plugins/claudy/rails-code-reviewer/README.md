# Rails Code Review Agent Plugin

A specialized Claude Code agent for automated Rails code review. This agent provides comprehensive code review focusing on Rails conventions, best practices, security, and performance.

## Installation

1. Copy the `.claude` directory to your Rails project root:

```bash
cp -r plugins/rails-code-review-agent/.claude /path/to/your/rails/project/
```

2. The agent will automatically be available for use in Claude Code

## Usage

The Rails reviewer agent can be invoked in several ways:

### Manual Invocation

Simply ask Claude to review your Rails code:

```
"Can you review my posts controller changes?"
"Please review the User model for best practices"
"Review these changes before I commit"
```

### Automatic Invocation

The agent can be configured to automatically review:

- Before git commits
- When certain files are modified
- Before creating pull requests

## What the Agent Reviews

### Models

- Validations and their correctness
- Association configurations
- Callback usage (identifying overuse)
- N+1 query potential
- Database indexing
- Scope definitions
- Separation of business logic

### Controllers

- Controller thickness (keeping them thin)
- Strong parameters
- Before actions
- Error handling
- Authentication/authorization
- HTTP status codes
- Response formats

### Views

- Logic-free views
- Proper partial usage
- Helper methods
- XSS protection
- Turbo/Hotwire patterns
- Accessibility

### Security

- Mass assignment protection
- SQL injection prevention
- XSS vulnerabilities
- CSRF protection
- Authentication/authorization
- Sensitive data exposure

### Performance

- N+1 query detection
- Database query efficiency
- Missing indexes
- Caching opportunities
- Eager loading recommendations

### Testing

- Test coverage
- Test quality
- Factory definitions
- Edge case coverage
- Proper mocking/stubbing

## Anti-Patterns Detected

The agent identifies and flags common Rails anti-patterns:

- Fat controllers with business logic
- God objects (models with too many responsibilities)
- Missing validations
- Callback overuse
- N+1 queries
- Logic in views
- Missing strong parameters
- Missing or inadequate tests
- Security vulnerabilities

## Review Output Format

The agent provides structured feedback:

```markdown
## Review Summary
High-level assessment of your changes

## Critical Issues
- Specific issues with file:line references

## Suggestions
- Actionable improvements

## Security Concerns
- Any security issues found

## Performance Notes
- Performance considerations

## Positive Observations
- Good practices you're following
```

## Configuration

### Custom Review Focus

You can ask the agent to focus on specific aspects:

```
"Review this focusing on security"
"Check for performance issues in this code"
"Review test coverage for these changes"
```

### Integration with Git Hooks

To automatically review before commits, add to `.claude/hooks/pre-commit`:

```bash
#!/bin/bash
# Trigger Rails code review before commit
echo "Running Rails code review..."
# Your hook logic here
```

## Best Practices Enforced

The agent enforces these Rails best practices:

1. **Convention Over Configuration**: Follow Rails conventions
2. **DRY Principle**: Don't Repeat Yourself
3. **RESTful Design**: Use RESTful routing patterns
4. **Thin Controllers**: Keep business logic out of controllers
5. **Fat Models, Skinny Controllers**: Or use service objects
6. **Security First**: Always consider security implications
7. **Test Coverage**: Ensure changes are tested
8. **Performance Awareness**: Watch for N+1 queries and inefficiencies

## Example Reviews

### Example 1: Controller Review

**Code:**

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.all
    @posts.each do |post|
      post.comments.count  # N+1 query!
    end
  end
end
```

**Agent Feedback:**

```markdown
## Critical Issues
- N+1 query detected in `app/controllers/posts_controller.rb:4`
  Loading comments for each post individually

## Suggestions
- Use eager loading: `Post.includes(:comments)`
- Consider using counter cache for comment counts
```

### Example 2: Model Review

**Code:**

```ruby
class User < ApplicationRecord
  has_many :posts
  # Missing validations!
end
```

**Agent Feedback:**

```markdown
## Critical Issues
- No validations defined for User model
- Missing email presence and format validation
- Missing unique index on email

## Suggestions
- Add validations for required fields
- Add unique index on email column
- Consider adding authentication validations
```

## Requirements

- Rails 7.0+
- Ruby 3.0+
- Claude Code CLI

## Contributing

To improve the agent's review capabilities:

1. Add new review patterns to the agent instructions
2. Include examples of common issues
3. Update anti-pattern detection
4. Enhance security checks

## License

MIT License - see LICENSE file

## Version

0.1.0 - Initial release

## Support

For issues and questions:

- GitHub Issues: [Create an issue]
- Documentation: See `/docs/best-practices/`
