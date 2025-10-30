# Rails Workflow Plugin - Tutorial

A comprehensive guide to using the Rails Workflow Plugin v2.0 with auto-invoking skills, quality gate hooks, and specialized agents.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Auto-Invoking Skills in Action](#auto-invoking-skills-in-action)
3. [Quality Gate Hooks](#quality-gate-hooks)
4. [Using Specialized Agents](#using-specialized-agents)
5. [Code Templates](#code-templates)
6. [Pattern Library](#pattern-library)
7. [Complete Workflow Example](#complete-workflow-example)

---

## Quick Start

### Installation

The Rails Workflow plugin is installed in your Claudy project. To use it in your Rails project:

```bash
cd your-rails-project
claude-code  # Start Claude Code session
```

### Verify Setup

```bash
# The plugin will automatically detect your Rails environment
# You should see confirmation when agents are invoked
```

---

## Auto-Invoking Skills in Action

Skills automatically activate when you modify Rails files. No explicit invocation needed!

### Example 1: Rails Conventions Skill

**Scenario:** You create a model with incorrect naming

```bash
# You: "Create a model for users"
# Claude creates: app/models/users.rb
```

**What Happens:**
```ruby
# app/models/users.rb
class Users < ApplicationRecord  # ❌ Wrong: plural class name
end
```

**Skill Activates Automatically:**
```
🔍 rails-conventions skill detected:
❌ Convention Violation: Model class name should be singular
Expected: User
Found: Users
File: app/models/users.rb:1
```

**Auto-Correction:**
```ruby
# app/models/user.rb
class User < ApplicationRecord  # ✅ Correct: singular class name
end
```

### Example 2: Security Patterns Skill

**Scenario:** You create a controller without strong parameters

```bash
# You: "Create a posts controller with create action"
```

**Initial Code:**
```ruby
def create
  @post = Post.create(params[:post])  # ❌ Mass assignment vulnerability
end
```

**Skill Activates:**
```
🔒 rails-security-patterns skill detected:
❌ Security: Mass assignment vulnerability
Location: app/controllers/posts_controller.rb:15
Fix: Define strong parameters method

Suggested fix:
def create
  @post = Post.create(post_params)
end

private

def post_params
  params.require(:post).permit(:title, :body, :published)
end
```

**Auto-Applied Fix:**
```ruby
def create
  @post = Post.create(post_params)  # ✅ Secure
end

private

def post_params
  params.require(:post).permit(:title, :body, :published)
end
```

### Example 3: Performance Patterns Skill

**Scenario:** You write code with N+1 query

```ruby
# app/controllers/posts_controller.rb
def index
  @posts = Post.all
  # Later in view: @posts.each { |post| post.author.name }
end
```

**Skill Activates:**
```
⚡ rails-performance-patterns skill detected:
❌ Performance: N+1 query detected
Location: app/controllers/posts_controller.rb:8

Problem:
- 1 query to load all posts
- N queries to load each post's author (one per post)

Solution:
@posts = Post.includes(:author).all
```

**Auto-Applied Fix:**
```ruby
def index
  @posts = Post.includes(:author).all  # ✅ Eager loading
end
```

---

## Quality Gate Hooks

Hooks run automatically before certain operations to prevent errors.

### Hook 1: Pre-Agent Invoke

**Blocks agents from running in non-Rails directories**

**Example:**
```bash
# You're in: /home/user/projects/nodejs-app
# You: "Create a Rails model for users"
```

**Hook Activates:**
```
🔍 Verifying Rails project structure...
❌ Error: No Gemfile found
This directory is not a Rails project.

Available options:
1. Navigate to your Rails project: cd /path/to/rails-app
2. Create a new Rails project: rails new myapp
```

**Prevents:**
- Running Rails agents in wrong directory
- Wasting time with incorrect setup
- Creating Rails files in non-Rails projects

### Hook 2: Pre-Commit

**Blocks commits with security issues, secrets, or debugging code**

**Example 1: Secrets Detection**
```bash
git add config/database.yml
git commit -m "Update database config"
```

**Hook Activates:**
```
🔍 Running pre-commit security checks...
❌ Error: Potential secrets detected

Found in config/database.yml:
  password: "my_secret_password"  # Line 8

Action required:
1. Use environment variables: ENV['DATABASE_PASSWORD']
2. Update your code
3. Run: git add config/database.yml
4. Try commit again
```

**Example 2: Debugger Statements**
```bash
git add app/services/payment_service.rb
git commit -m "Add payment processing"
```

**Hook Activates:**
```
🔍 Running pre-commit security checks...
❌ Error: Debugger statements detected

Found in app/services/payment_service.rb:
  binding.pry  # Line 42

Debuggers should not be committed.
Remove debugging code and try again.
```

**Example 3: SQL Injection**
```bash
git add app/controllers/users_controller.rb
git commit -m "Add search"
```

**Hook Activates:**
```
🔍 Running pre-commit security checks...
❌ Error: SQL injection vulnerability detected

Found in app/controllers/users_controller.rb:
  User.where("name = '#{params[:name]}'")  # Line 23

Security risk: String interpolation in SQL
Fix: Use parameterized queries
  User.where("name = ?", params[:name])
  # or
  User.where(name: params[:name])
```

---

## Using Specialized Agents

### Example: Building a Complete Feature

**Request:**
```
Create a complete blog post system with:
- Post model with title, body, published status
- CRUD API endpoints
- Comments on posts
- Tests for everything
```

**What Happens:**

#### 1. Rails Architect Agent Activates

```
🤖 @rails-architect activated

Analyzing feature requirements...
✅ Detected: Multi-component feature requiring 4 specialists

Workflow Plan:
1. @rails-model-specialist: Create Post and Comment models
2. @rails-controller-specialist: Create PostsController and CommentsController
3. @rails-test-specialist: Create model and controller specs
4. @rails-service-specialist: Create CommentNotificationService

Execution Strategy: Sequential (models → controllers → tests → services)
Estimated time: 3-5 minutes
```

#### 2. Model Specialist Runs

```
🤖 @rails-model-specialist activated

Creating models...
✅ Created app/models/post.rb
   - Validations: title (presence), body (presence, length: 10..10000)
   - Associations: has_many :comments, dependent: :destroy
   - Scopes: published, recent
   - Methods: publish!, unpublish!

✅ Created app/models/comment.rb
   - Validations: body (presence, length: 2..1000)
   - Associations: belongs_to :post, belongs_to :user
   - Callbacks: after_create_commit :notify_author

✅ Created db/migrate/20241030_create_posts.rb
✅ Created db/migrate/20241030_create_comments.rb

🔍 rails-conventions skill: All models follow naming conventions ✅
🔒 rails-security-patterns skill: No security issues detected ✅
```

#### 3. Controller Specialist Runs

```
🤖 @rails-controller-specialist activated

Creating controllers...
✅ Created app/controllers/api/v1/posts_controller.rb
   - Actions: index, show, create, update, destroy
   - Strong parameters: post_params
   - Authentication: before_action :authenticate_user!
   - Authorization: before_action :authorize_author, only: [:update, :destroy]

✅ Created app/controllers/api/v1/comments_controller.rb
   - Actions: index, create, destroy
   - Nested under posts: /api/v1/posts/:post_id/comments
   - Strong parameters: comment_params

🔒 rails-security-patterns skill: All controllers use strong params ✅
⚡ rails-performance-patterns skill: Added eager loading to index actions ✅
```

#### 4. Test Specialist Runs

```
🤖 @rails-test-specialist activated

Creating tests...
✅ Created spec/models/post_spec.rb
   - 12 examples: validations, associations, scopes, methods
   - Coverage: 100%

✅ Created spec/models/comment_spec.rb
   - 8 examples: validations, associations, callbacks
   - Coverage: 100%

✅ Created spec/requests/api/v1/posts_spec.rb
   - 15 examples: CRUD operations, authentication, authorization
   - Coverage: 100%

✅ Created spec/requests/api/v1/comments_spec.rb
   - 10 examples: create, destroy, nested routes
   - Coverage: 100%

Running tests...
✅ All 45 examples passed in 2.34 seconds
```

#### 5. Service Specialist Runs

```
🤖 @rails-service-specialist activated

Creating services...
✅ Created app/services/comment_notification_service.rb
   - Purpose: Notify post author when comment is created
   - Pattern: Service object with .call method
   - Error handling: Transaction with rollback
   - Background job: Enqueues SendCommentNotificationJob

✅ Created app/jobs/send_comment_notification_job.rb
   - Queue: default
   - Retry: 5 attempts with exponential backoff
```

#### 6. Summary

```
🎉 Feature Complete!

Created:
- 2 models (Post, Comment)
- 2 migrations
- 2 controllers (PostsController, CommentsController)
- 4 test files (45 passing examples)
- 1 service (CommentNotificationService)
- 1 background job (SendCommentNotificationJob)

Quality Checks:
✅ All conventions followed
✅ No security issues
✅ Performance optimized
✅ 100% test coverage

Next steps:
1. Run migrations: rails db:migrate
2. Start server: rails server
3. Test endpoints: curl http://localhost:3000/api/v1/posts
```

---

## Code Templates

The plugin includes 5 code templates for generating consistent Rails code.

### Using Templates

**Example 1: Generate Model**
```
You: "Use the model template to create a User model with email, name, and admin role"
```

**Template Applied:**
```ruby
# frozen_string_literal: true

# User account model
class User < ApplicationRecord
  # == Constants ============================================================
  ROLES = %w[user admin].freeze

  # == Validations ==========================================================
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, inclusion: { in: ROLES }

  # == Scopes ===============================================================
  scope :admins, -> { where(role: 'admin') }
  scope :active, -> { where(active: true) }

  # == Instance Methods =====================================================
  def admin?
    role == 'admin'
  end
end
```

**Example 2: Generate Controller**
```
You: "Use the controller template for a Products API controller"
```

**Template Applied:**
```ruby
# frozen_string_literal: true

# Products API controller
class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[show update destroy]

  # GET /api/v1/products
  def index
    @products = Product.all
    render json: @products
  end

  # GET /api/v1/products/:id
  def show
    render json: @product
  end

  # POST /api/v1/products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/products/:id
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :price, :description, :stock)
  end
end
```

---

## Pattern Library

The plugin includes 6 comprehensive pattern guides.

### Accessing Pattern Library

**Example 1: API Patterns**
```
You: "How do I implement pagination in my Rails API?"
```

**Agent Response:**
```
Let me reference the API patterns guide...

📚 From patterns/api-patterns.md - Pagination section:

I recommend using Kaminari for pagination:

1. Add to Gemfile:
   gem 'kaminari'

2. Controller:
   def index
     @posts = Post.page(params[:page]).per(params[:per_page] || 25)
     render json: @posts, meta: pagination_meta(@posts)
   end

   private

   def pagination_meta(collection)
     {
       current_page: collection.current_page,
       next_page: collection.next_page,
       prev_page: collection.prev_page,
       total_pages: collection.total_pages,
       total_count: collection.total_count
     }
   end

Would you like me to implement this for your Posts API?
```

**Example 2: Authentication Patterns**
```
You: "I need to add JWT authentication to my API"
```

**Agent Response:**
```
📚 Referencing patterns/authentication-patterns.md...

For JWT authentication, I recommend Devise with devise-jwt:

Setup:
1. Add gems: devise, devise-jwt
2. Configure JWT revocation strategy
3. Create sessions and registrations controllers

Let me implement this for you:
- JwtDenylist model
- Devise configuration
- API::V1::SessionsController
- API::V1::RegistrationsController

This will give you:
✅ POST /api/v1/login (returns JWT token)
✅ DELETE /api/v1/logout (revokes token)
✅ POST /api/v1/signup (creates user, returns JWT)

Shall I proceed?
```

### Available Pattern Guides

1. **api-patterns.md** - RESTful design, versioning, pagination, serialization, error handling, rate limiting, CORS
2. **authentication-patterns.md** - Devise+JWT, OAuth, 2FA, API keys, password security, session management
3. **background-job-patterns.md** - Solid Queue, Sidekiq, job design, retries, scheduling, monitoring
4. **caching-patterns.md** - Fragment caching, low-level caching, HTTP caching, Russian doll, invalidation, Redis
5. **real-time-patterns.md** - Turbo Streams, Action Cable, broadcasting, presence channels, performance
6. **testing-patterns.md** - RSpec setup, model/controller/request tests, factories, coverage, CI

---

## Complete Workflow Example

### Scenario: Build a Task Management API

**Initial Request:**
```
Create a complete task management API with:
- Tasks with title, description, status (pending/in_progress/completed)
- Task assignments to users
- Comments on tasks
- Email notifications when tasks are assigned
- Tests for everything
```

### Step-by-Step Execution

#### Step 1: Architect Plans Workflow

```
🤖 @rails-architect analyzing request...

Detected requirements:
✅ Models: Task, TaskAssignment, Comment, User
✅ Controllers: TasksController, CommentsController
✅ Services: TaskAssignmentService (handles notifications)
✅ Jobs: SendTaskAssignmentEmailJob
✅ Tests: Model, request, and service specs

Workflow:
1. Models (parallel): Task, TaskAssignment, Comment
2. Controllers (sequential): TasksController, CommentsController
3. Service: TaskAssignmentService
4. Job: SendTaskAssignmentEmailJob
5. Tests: All specs (parallel)

Launching specialists...
```

#### Step 2: Models Created

```
🤖 @rails-model-specialist

✅ app/models/task.rb
   class Task < ApplicationRecord
     STATUSES = %w[pending in_progress completed].freeze

     belongs_to :creator, class_name: 'User'
     has_many :task_assignments, dependent: :destroy
     has_many :assigned_users, through: :task_assignments, source: :user
     has_many :comments, dependent: :destroy

     validates :title, presence: true
     validates :status, inclusion: { in: STATUSES }

     scope :pending, -> { where(status: 'pending') }
     scope :completed, -> { where(status: 'completed') }
   end

🔍 rails-conventions: ✅ All naming conventions followed
🔒 rails-security-patterns: ✅ No security issues
⚡ rails-performance-patterns: ✅ No N+1 queries possible
```

#### Step 3: Controllers with Security

```
🤖 @rails-controller-specialist

✅ app/controllers/api/v1/tasks_controller.rb
   - Strong parameters: ✅
   - Authentication required: ✅
   - Authorization checks: ✅
   - N+1 prevention: includes(:creator, :assigned_users)

🔒 rails-security-patterns auto-applied:
   - Mass assignment protection: ✅
   - SQL injection prevention: ✅
   - Authorization on update/destroy: ✅
```

#### Step 4: Service with Transaction

```
🤖 @rails-service-specialist

✅ app/services/task_assignment_service.rb
   class TaskAssignmentService
     def initialize(task, user_ids)
       @task = task
       @user_ids = user_ids
     end

     def call
       ApplicationRecord.transaction do
         @task.task_assignments.destroy_all
         @user_ids.each do |user_id|
           assignment = @task.task_assignments.create!(user_id: user_id)
           SendTaskAssignmentEmailJob.perform_later(assignment.id)
         end
       end
     rescue StandardError => e
       Rails.logger.error("Task assignment failed: #{e.message}")
       raise
     end
   end
```

#### Step 5: Tests with 100% Coverage

```
🤖 @rails-test-specialist

✅ Created 6 test files:
   - spec/models/task_spec.rb (15 examples)
   - spec/models/task_assignment_spec.rb (8 examples)
   - spec/models/comment_spec.rb (10 examples)
   - spec/requests/api/v1/tasks_spec.rb (20 examples)
   - spec/requests/api/v1/comments_spec.rb (12 examples)
   - spec/services/task_assignment_service_spec.rb (14 examples)

Running tests...
✅ 79 examples, 0 failures
✅ Coverage: 100%
```

#### Step 6: Pre-Commit Hook Verification

```
Attempting git commit...

🔍 Running pre-commit security checks...
✅ No secrets detected
✅ No debugger statements
✅ No SQL injection vulnerabilities
✅ All security checks passed

Commit allowed!
```

### Final Result

```
🎉 Task Management API Complete!

Created 18 files:
- 4 models
- 4 migrations
- 2 controllers
- 1 service
- 1 background job
- 6 test files

Quality Metrics:
✅ 100% test coverage (79 passing examples)
✅ All Rails conventions followed
✅ Zero security vulnerabilities
✅ No performance issues (eager loading applied)
✅ All hooks passed

Ready to use:
1. Run migrations: rails db:migrate
2. Start server: rails server
3. Test API:
   POST /api/v1/tasks
   GET /api/v1/tasks/:id
   POST /api/v1/tasks/:id/comments
   PATCH /api/v1/tasks/:id (assign users)

Documentation:
- API patterns: patterns/api-patterns.md
- Auth patterns: patterns/authentication-patterns.md
- Testing guide: patterns/testing-patterns.md
```

---

## Tips and Best Practices

### 1. Let Skills Work Automatically

**Don't:**
```
You: "Check my code for Rails conventions"
```

**Do:**
```
You: "Create a User model"
# Skills automatically check conventions
```

### 2. Trust the Quality Gates

**Don't try to bypass hooks:**
```bash
SKIP_RAILS_HOOKS=1 git commit  # Bad practice
```

**Do fix the issues:**
```
# Hook blocks commit with debugger
# Remove debugger statement
# Commit again successfully
```

### 3. Use the Pattern Library

**Don't:**
```
You: "How do I do JWT authentication in Rails?"
```

**Do:**
```
You: "Implement JWT authentication following the authentication patterns guide"
# Agent references patterns/authentication-patterns.md automatically
```

### 4. Leverage Specialized Agents

**Don't:**
```
You: "Add some tests"
```

**Do:**
```
You: "Use @rails-test-specialist to create comprehensive tests for my Task model"
# Specific agent, clear scope
```

### 5. Request Complete Workflows

**Don't:**
```
You: "Create a Post model"
# Later: "Now create the controller"
# Later: "Now add tests"
```

**Do:**
```
You: "Create a complete Post feature with model, controller, and tests"
# @rails-architect coordinates everything
```

---

## Troubleshooting

### Issue: Skills Not Activating

**Symptom:** Code has issues but no skill warnings appear

**Solution:**
- Skills auto-invoke only on file changes
- Manually request: "Run rails-security-patterns skill on my controller"

### Issue: Hook Blocking Valid Code

**Symptom:** Pre-commit hook blocks legitimate code

**Solution:**
- Review the specific warning
- If false positive, add exception to hooks/pre-commit.sh
- Or temporarily skip: `SKIP_RAILS_HOOKS=1 git commit`

### Issue: Agent Not Found

**Symptom:** "@rails-model-specialist not found"

**Solution:**
- Ensure you're in a Rails project directory
- Check plugin is installed: `ls plugins/claudy/rails-workflow`
- Restart Claude Code session

---

## Next Steps

1. **Explore Pattern Guides:** Read through all 6 pattern guides in `patterns/` directory
2. **Try Building Features:** Use the complete workflow example as a template
3. **Customize Templates:** Edit templates in `templates/` to match your team's style
4. **Contribute:** Share your patterns and improvements with the community

---

**Happy Rails Development with Claude Code!** 🚀
