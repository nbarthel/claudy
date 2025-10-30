---
name: rails-security-patterns
description: Automatically validates security best practices and prevents vulnerabilities
auto_invoke: true
trigger_on: [file_create, file_modify]
file_patterns: ["**/controllers/**/*.rb", "**/models/**/*.rb"]
tags: [rails, security, authentication, authorization, sql-injection]
priority: 1
version: 2.0
---

# Rails Security Patterns Skill

Auto-validates security best practices and blocks common vulnerabilities.

## What This Skill Does

**Automatic Security Checks:**
- Strong parameters in controllers (prevents mass assignment)
- SQL injection prevention (parameterized queries)
- CSRF token handling (API mode considerations)
- Authentication presence
- Authorization checks

**When It Activates:**
- Controller files created or modified
- Model files with database queries modified
- Authentication-related changes

## Security Checks

### 1. Strong Parameters

**Checks:**
- Every `create` and `update` action uses strong parameters
- No direct `params` usage in model instantiation
- `permit` calls include only expected attributes

**Example Violation:**
```ruby
# BAD
def create
  @user = User.create(params[:user])  # ❌ Mass assignment
end

# GOOD
def create
  @user = User.create(user_params)  # ✅ Strong params
end

private

def user_params
  params.require(:user).permit(:name, :email)
end
```

**Skill Output:**
```
❌ Security: Mass assignment vulnerability
Location: app/controllers/users_controller.rb:15
Issue: params[:user] used directly without strong parameters

Fix: Define strong parameters method:
private

def user_params
  params.require(:user).permit(:name, :email, :role)
end

Then use: @user = User.create(user_params)
```

### 2. SQL Injection Prevention

**Checks:**
- No string interpolation in `where` clauses
- Parameterized queries used
- No raw SQL without placeholders

**Example Violation:**
```ruby
# BAD
User.where("email = '#{params[:email]}'")  # ❌ SQL injection
User.where("name LIKE '%#{params[:query]}%'")  # ❌ SQL injection

# GOOD
User.where("email = ?", params[:email])  # ✅ Parameterized
User.where("name LIKE ?", "%#{params[:query]}%")  # ✅ Safe
User.where(email: params[:email])  # ✅ Hash syntax
```

**Skill Output:**
```
❌ Security: SQL injection vulnerability
Location: app/models/user.rb:45
Issue: String interpolation in SQL query

Vulnerable code:
User.where("email = '#{email}'")

Fix: Use parameterized query:
User.where("email = ?", email)

Or use hash syntax:
User.where(email: email)
```

### 3. Authentication Checks

**Checks:**
- Controllers have authentication filters
- Sensitive actions require authentication
- Token-based auth for API endpoints

**Example:**
```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!  # ✅ Auth required

  def index
    # ...
  end
end
```

**Skill Output (if missing):**
```
⚠️  Security: No authentication found
Location: app/controllers/admin/users_controller.rb
Issue: Admin controller without authentication

Recommendation: Add authentication:
before_action :authenticate_user!
before_action :require_admin!
```

### 4. Authorization Checks

**Checks:**
- Update/destroy actions verify ownership
- Role-based access control present
- Resource-level authorization

**Example:**
```ruby
# BAD
def destroy
  @post = Post.find(params[:id])
  @post.destroy  # ❌ No ownership check
end

# GOOD
def destroy
  @post = current_user.posts.find(params[:id])  # ✅ Scoped to user
  @post.destroy
end

# BETTER
def destroy
  @post = Post.find(params[:id])
  authorize @post  # ✅ Using Pundit/CanCanCan
  @post.destroy
end
```

**Skill Output:**
```
⚠️  Security: Missing authorization check
Location: app/controllers/posts_controller.rb:42
Issue: destroy action without ownership verification

Recommendation: Add authorization:
Option 1 (scope to user):
@post = current_user.posts.find(params[:id])

Option 2 (use authorization gem):
authorize @post  # Pundit
authorize! :destroy, @post  # CanCanCan
```

### 5. Sensitive Data Exposure

**Checks:**
- No passwords in logs
- API keys not hardcoded
- Secrets use environment variables

**Example Violation:**
```ruby
# BAD
API_KEY = "sk_live_abc123..."  # ❌ Hardcoded secret

# GOOD
API_KEY = ENV['STRIPE_API_KEY']  # ✅ Environment variable
```

**Skill Output:**
```
❌ Security: Hardcoded secret detected
Location: config/initializers/stripe.rb:3
Issue: API key hardcoded in source

Fix: Use environment variable:
API_KEY = ENV['STRIPE_API_KEY']

Add to .env (don't commit):
STRIPE_API_KEY=sk_live_your_key_here
```

## Integration with Pre-commit Hook

This skill works with the pre-commit hook to block unsafe commits:

**Automatic blocks:**
- SQL injection vulnerabilities
- Missing strong parameters in create/update actions
- Hardcoded secrets/API keys
- Mass assignment vulnerabilities

**Warnings (allow commit):**
- Missing authentication (might be intentional for public endpoints)
- Missing authorization (might use custom logic)
- Complex queries (performance concern, not security)

## Configuration

Create `.rails-security.yml` to customize:

```yaml
# .rails-security.yml
strong_parameters:
  enforce: true
  block_commit: true

sql_injection:
  enforce: true
  block_commit: true

authentication:
  require_for_controllers: true
  exceptions:
    - Api::V1::PublicController
    - PagesController

authorization:
  warn_on_missing: true
  block_commit: false

secrets:
  detect_patterns:
    - "sk_live_"
    - "api_key"
    - "password"
    - "secret"
  block_commit: true
```

## Common Patterns

### API Authentication

**Token-based:**
```ruby
class Api::BaseController < ActionController::API
  before_action :authenticate_token!

  private

  def authenticate_token!
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by(api_token: token)
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end
```

### Scope to User

**Pattern:**
```ruby
# Always scope to current_user when possible
@posts = current_user.posts
@post = current_user.posts.find(params[:id])

# Prevents accessing other users' resources
```

### Rate Limiting

**Recommendation:**
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
Rack::Attack.throttle('api/ip', limit: 100, period: 1.minute) do |req|
  req.ip if req.path.start_with?('/api/')
end
```

## References

- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Rails Security Guide**: https://guides.rubyonrails.org/security.html
- **Pattern Library**: /patterns/authentication-patterns.md

---

**This skill runs automatically and blocks security vulnerabilities before they reach production.**
