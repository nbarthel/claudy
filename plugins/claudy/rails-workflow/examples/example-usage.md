# Rails Dev Workflow - Example Usage Scenarios

This document provides detailed examples of using the Rails Dev Workflow plugin for common development tasks.

## Table of Contents

1. [Building a Blog Application](#building-a-blog-application)
2. [Adding User Authentication](#adding-user-authentication)
3. [Creating API Endpoints](#creating-api-endpoints)
4. [Refactoring Fat Controllers](#refactoring-fat-controllers)
5. [Implementing Real-time Features](#implementing-real-time-features)
6. [Setting Up Deployment](#setting-up-deployment)

---

## Building a Blog Application

### Scenario

You want to build a blog with posts, comments, and tags.

### Step 1: Create the Post Feature

```
You: /rails-feature Blog post with title, body, and author
```

**What the Architect Coordinates:**

1. **rails-models** creates:
   - Migration for posts table
   - Post model with validations
   - Associations to User
   - Published scope

2. **rails-controllers** creates:
   - PostsController with CRUD actions
   - Strong parameters
   - Authorization checks

3. **rails-views** creates:
   - posts/index.html.erb
   - posts/show.html.erb
   - posts/_form.html.erb
   - posts/_post.html.erb partial

4. **rails-tests** creates:
   - Post model specs
   - PostsController specs
   - Request specs
   - System specs

**Result:**
Complete post management with index, show, new, create, edit, update, destroy actions.

### Step 2: Add Comments

```
You: /rails-feature Comments on posts with real-time updates using Turbo
```

**What the Architect Coordinates:**

1. **rails-models** creates:
   - Comment model with validation
   - belongs_to :post, :user associations
   - Counter cache for post

2. **rails-controllers** creates:
   - Nested CommentsController
   - Turbo Stream responses

3. **rails-views** creates:
   - comments/_comment.html.erb
   - comments/_form.html.erb
   - comments/create.turbo_stream.erb
   - comments/destroy.turbo_stream.erb
   - Turbo Frame in posts/show

4. **rails-tests** creates:
   - Comment model specs
   - System specs with JavaScript driver

**Result:**
Real-time commenting without page reloads using Turbo Streams.

### Step 3: Add Tagging System

```
You: /rails-dev Add a tagging system where posts can have multiple tags
```

**What the Architect Coordinates:**

1. **rails-models** creates:
   - Tag model
   - PostTag join model
   - has_many :through associations
   - Unique validation on tag names

2. **rails-controllers** updates:
   - PostsController to handle tag_ids
   - Tags controller for tag management

3. **rails-views** updates:
   - Form with tag selection
   - Tag display on posts
   - Tag filtering on index

**Result:**
Complete tagging system with many-to-many relationships.

---

## Adding User Authentication

### Scenario

You need user registration, login, and authentication.

### Using Devise (Recommended)

```
You: /rails-feature User authentication using Devise
```

**What the Architect Coordinates:**

1. **rails-models** installs and configures:
   - Devise gem
   - User model with devise modules
   - Database migration

2. **rails-controllers** creates:
   - Devise controllers customization
   - Authentication helpers
   - before_action filters

3. **rails-views** creates:
   - devise/sessions/new.html.erb
   - devise/registrations/new.html.erb
   - devise/passwords views
   - Navigation with login/logout

4. **rails-tests** creates:
   - User model specs
   - Authentication integration specs

**Result:**
Complete authentication system with registration, login, password reset.

### Custom Authentication

```
You: /rails-feature Custom user authentication without Devise
```

**Result:**
Custom-built authentication with bcrypt, sessions controller, and manual implementation.

---

## Creating API Endpoints

### Scenario

You need JSON API endpoints for a mobile app.

### Step 1: Create API Structure

```
You: /rails-feature API v1 endpoints for posts
```

**What the Architect Coordinates:**

1. **rails-controllers** creates:
   - Api::V1 namespace
   - Api::V1::PostsController
   - JSON responses with serialization
   - Pagination support
   - Error handling

2. **rails-models** updates:
   - User model with API token authentication

3. **rails-tests** creates:
   - API request specs
   - Authentication specs
   - JSON response validation

**Routes Created:**

```ruby
namespace :api do
  namespace :v1 do
    resources :posts, only: [:index, :show, :create, :update, :destroy]
  end
end
```

### Step 2: Add Authentication

```
You: /rails-dev Add token-based authentication for the API
```

**What Gets Added:**

- API token generation for users
- Token authentication in Api::V1::BaseController
- Secure token handling
- Authentication specs

---

## Refactoring Fat Controllers

### Scenario

Your PostsController has grown to include complex publication logic.

### Before

```ruby
# app/controllers/posts_controller.rb
def publish
  @post = Post.find(params[:id])

  if current_user != @post.user && !current_user.admin?
    redirect_to root_path, alert: 'Not authorized'
    return
  end

  if @post.published?
    redirect_to @post, alert: 'Already published'
    return
  end

  ActiveRecord::Base.transaction do
    @post.update!(published: true, published_at: Time.current)

    # Send notifications
    @post.user.followers.each do |follower|
      NotificationMailer.new_post(follower, @post).deliver_later
    end

    # Track analytics
    Analytics.track(
      user_id: current_user.id,
      event: 'post_published',
      post_id: @post.id
    )

    # Update search index
    SearchIndex.update(@post)
  end

  redirect_to @post, notice: 'Post published!'
rescue => e
  Rails.logger.error("Failed to publish: #{e.message}")
  redirect_to @post, alert: 'Failed to publish post'
end
```

### Refactor Command

```
You: /rails-refactor Extract post publication logic to a service object
```

**What the Architect Coordinates:**

1. **rails-services** creates:

```ruby
# app/services/posts/publish_service.rb
module Posts
  class PublishService
    def initialize(post, publisher:)
      @post = post
      @publisher = publisher
    end

    def call
      return failure(:unauthorized) unless authorized?
      return failure(:already_published) if post.published?

      ActiveRecord::Base.transaction do
        publish_post!
        notify_followers
        track_analytics
        update_search_index
      end

      success(post)
    rescue => e
      Rails.logger.error("Publication failed: #{e.message}")
      failure(:publication_failed, e.message)
    end

    private
    # ... implementation
  end
end
```

2. **rails-controllers** updates:

```ruby
# app/controllers/posts_controller.rb
def publish
  @post = Post.find(params[:id])
  result = Posts::PublishService.new(@post, publisher: current_user).call

  if result.success?
    redirect_to @post, notice: 'Post published!'
  else
    redirect_to @post, alert: error_message(result)
  end
end
```

3. **rails-tests** creates:
   - Service object specs with all edge cases
   - Updated controller specs

**Result:**
Clean controller, testable service object, better separation of concerns.

---

## Implementing Real-time Features

### Scenario

Add a live chat feature using Turbo Streams.

### Command

```
You: /rails-feature Real-time chat with rooms and messages using Turbo Streams
```

**What the Architect Coordinates:**

1. **rails-models** creates:

```ruby
# app/models/chat_room.rb
class ChatRoom < ApplicationRecord
  has_many :messages, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
end

# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :chat_room
  belongs_to :user

  validates :body, presence: true

  after_create_commit -> { broadcast_message }

  private

  def broadcast_message
    broadcast_prepend_to chat_room,
      target: "messages",
      partial: "messages/message",
      locals: { message: self }
  end
end
```

2. **rails-controllers** creates:

```ruby
# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def create
    @message = @chat_room.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chat_room }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

3. **rails-views** creates:

```erb
<!-- app/views/chat_rooms/show.html.erb -->
<%= turbo_stream_from @chat_room %>

<div id="messages">
  <%= render @messages %>
</div>

<%= turbo_frame_tag "new_message" do %>
  <%= render "messages/form", chat_room: @chat_room, message: Message.new %>
<% end %>
```

4. **rails-tests** creates:
   - System specs with JavaScript
   - Turbo Stream integration tests

**Result:**
Working real-time chat with instant message delivery to all participants.

---

## Setting Up Deployment

### Scenario

Deploy your Rails app to production using Docker and Kamal.

### Step 1: Docker Configuration

```
You: /rails-dev Set up Docker for my Rails application
```

**What rails-devops Creates:**

1. **Dockerfile** - Multi-stage build optimized for production
2. **docker-compose.yml** - Development environment with PostgreSQL, Redis
3. **.dockerignore** - Exclude unnecessary files
4. **Health check endpoint** - For container orchestration

### Step 2: Kamal Deployment

```
You: /rails-dev Configure Kamal for production deployment
```

**What rails-devops Creates:**

1. **config/deploy.yml** - Kamal configuration
2. **Traefik setup** - Load balancer with SSL
3. **Environment variables** - Secure secrets management
4. **Accessories** - PostgreSQL, Redis configuration
5. **Documentation** - Deployment guide

### Step 3: CI/CD Pipeline

```
You: /rails-dev Set up GitHub Actions for CI/CD
```

**What rails-devops Creates:**

1. **.github/workflows/ci.yml** - Run tests, linting, security scans
2. **.github/workflows/deploy.yml** - Automated deployment to production
3. **Test coverage reporting** - Integration with Codecov
4. **Security scanning** - Brakeman integration

**Result:**
Complete deployment pipeline from git push to production deployment.

---

## Advanced Workflows

### Multi-tenant Application

```
You: /rails-dev Add multi-tenancy using the Apartment gem
```

### Background Jobs

```
You: /rails-dev Set up Sidekiq for background job processing
```

### Full-text Search

```
You: /rails-dev Add full-text search using pg_search
```

### File Uploads

```
You: /rails-dev Add image uploads with Active Storage and image processing
```

### Admin Dashboard

```
You: /rails-feature Admin dashboard for managing posts and users
```

---

## Tips for Success

### 1. Be Specific in Requests

❌ Bad: "Add posts"
✅ Good: "Create a Post model with title, body, published status, belongs to User, with RESTful controller and views"

### 2. Break Down Complex Features

Instead of: "Build a complete social media app"

Do:

1. `/rails-feature User profiles`
2. `/rails-feature Posts with likes and shares`
3. `/rails-feature Following system`
4. `/rails-feature News feed`

### 3. Iterate and Refine

Initial implementation:

```
/rails-feature User authentication
```

Then enhance:

```
/rails-dev Add two-factor authentication
/rails-dev Add OAuth login with Google
/rails-refactor Optimize authentication queries
```

### 4. Review Generated Code

The agents follow best practices, but always review:

- Security implications
- Performance considerations
- Project-specific requirements

### 5. Leverage Multiple Commands

Combine commands for workflows:

```
/rails-feature Blog posts       # Create initial feature
/rails-dev Add commenting       # Add related feature
/rails-refactor posts controller # Clean up code
/rails-dev Add deployment       # Deploy to production
```

---

## Getting Help

If you encounter issues:

1. **Check the agents**: Review agent prompts in `agents/` directory
2. **Read the README**: Comprehensive documentation
3. **Try specific agents**: Invoke specialized agents directly via Task tool
4. **Iterate**: Start simple, then add complexity

---

## Next Steps

Explore the [README](../README.md) for:

- Complete agent descriptions
- Installation instructions
- Rails conventions followed
- Troubleshooting guide

Happy Rails development!
