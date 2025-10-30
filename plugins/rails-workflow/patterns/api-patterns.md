# Rails API Patterns Guide

Comprehensive patterns for building robust, scalable Rails APIs.

---

## Table of Contents

1. [RESTful API Design](#restful-api-design)
2. [API Versioning](#api-versioning)
3. [Pagination](#pagination)
4. [Serialization](#serialization)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)
7. [CORS Configuration](#cors-configuration)

---

## RESTful API Design

### Standard Resource Routes

**Good Example:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :posts do
        resources :comments, only: [:index, :create]
        member do
          post :publish
        end
        collection do
          get :trending
        end
      end
    end
  end
end

# Controller
class Api::V1::PostsController < ApplicationController
  # GET /api/v1/posts
  def index
    @posts = Post.published.page(params[:page])
    render json: @posts
  end

  # GET /api/v1/posts/:id
  def show
    @post = Post.find(params[:id])
    render json: @post
  end

  # POST /api/v1/posts
  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post, status: :created, location: api_v1_post_url(@post)
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/posts/:id
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/posts/:id
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    head :no_content
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
```

**Bad Example:**
```ruby
# ❌ Non-RESTful endpoints
post '/api/posts/create_new_post'
get '/api/get_post_by_id/:id'
post '/api/delete_post/:id'

# ❌ Mixing concerns in single endpoint
post '/api/posts/create_and_publish'

# ❌ No API versioning
get '/api/posts'
```

**When to Use:**
- Building any API that exposes resources
- Creating CRUD operations
- Standard client-server communication

---

## API Versioning

### Namespace-Based Versioning (Recommended)

**Good Example:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :posts
      resources :users
    end

    namespace :v2 do
      resources :posts  # Different implementation
      resources :users
    end
  end
end

# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      # v1-specific configuration
      before_action :authenticate_api_v1_user
    end
  end
end

# app/controllers/api/v2/base_controller.rb
module Api
  module V2
    class BaseController < ApplicationController
      # v2-specific configuration
      before_action :authenticate_api_v2_user
    end
  end
end

# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < BaseController
      def index
        @posts = Post.all
        render json: @posts, each_serializer: V1::PostSerializer
      end
    end
  end
end

# app/controllers/api/v2/posts_controller.rb
module Api
  module V2
    class PostsController < BaseController
      def index
        # v2 includes more fields and pagination
        @posts = Post.includes(:author, :tags).page(params[:page])
        render json: @posts, each_serializer: V2::PostSerializer
      end
    end
  end
end
```

**Header-Based Versioning:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    scope module: :v1, constraints: ApiVersion.new(version: 1, default: true) do
      resources :posts
    end

    scope module: :v2, constraints: ApiVersion.new(version: 2) do
      resources :posts
    end
  end
end

# lib/api_version.rb
class ApiVersion
  attr_reader :version, :default

  def initialize(version:, default: false)
    @version = version
    @default = default
  end

  def matches?(request)
    @default || check_headers(request.headers)
  end

  private

  def check_headers(headers)
    accept = headers['Accept']
    accept&.include?("application/vnd.myapp.v#{@version}+json")
  end
end

# Client usage:
# curl -H "Accept: application/vnd.myapp.v2+json" https://api.example.com/posts
```

**When to Use:**
- Breaking API changes
- Long-term API support requirements
- Multiple client versions in production

---

## Pagination

### Kaminari Pagination (Recommended)

**Good Example:**
```ruby
# Gemfile
gem 'kaminari'

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
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
end

# Response format:
# {
#   "data": [...],
#   "meta": {
#     "current_page": 1,
#     "next_page": 2,
#     "prev_page": null,
#     "total_pages": 10,
#     "total_count": 247
#   }
# }
```

**Pagy Pagination (High Performance):**
```ruby
# Gemfile
gem 'pagy'

# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include Pagy::Backend
end

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  def index
    @pagy, @posts = pagy(Post.all, items: params[:per_page] || 25)

    render json: @posts, meta: pagy_metadata(@pagy)
  end

  private

  def pagy_metadata(pagy)
    {
      current_page: pagy.page,
      next_page: pagy.next,
      prev_page: pagy.prev,
      total_pages: pagy.pages,
      total_count: pagy.count,
      per_page: pagy.items
    }
  end
end
```

**Cursor-Based Pagination (Large Datasets):**
```ruby
class Api::V1::PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc)

    if params[:cursor]
      cursor_post = Post.find_by(id: params[:cursor])
      @posts = @posts.where('created_at < ?', cursor_post.created_at)
    end

    @posts = @posts.limit(params[:per_page] || 25)

    render json: @posts, meta: {
      next_cursor: @posts.last&.id,
      has_more: @posts.count == (params[:per_page] || 25).to_i
    }
  end
end
```

**When to Use:**
- Any endpoint returning collections
- Kaminari: Standard pagination needs
- Pagy: High-performance requirements (40x faster than Kaminari)
- Cursor-based: Real-time feeds, infinite scroll, large datasets

---

## Serialization

### ActiveModel::Serializer

**Good Example:**
```ruby
# Gemfile
gem 'active_model_serializers'

# app/serializers/post_serializer.rb
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :published_at, :view_count

  belongs_to :author, serializer: UserSerializer
  has_many :comments, serializer: CommentSerializer

  # Computed attributes
  def view_count
    object.views.count
  end
end

# app/serializers/user_serializer.rb
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :avatar_url

  # Conditional attributes
  attribute :email, if: :show_email?

  def show_email?
    scope&.admin? || scope == object
  end
end

# Controller usage:
class Api::V1::PostsController < ApplicationController
  def show
    @post = Post.includes(:author, :comments).find(params[:id])
    render json: @post, serializer: PostSerializer
  end
end
```

**Blueprinter (Fast Serialization):**
```ruby
# Gemfile
gem 'blueprinter'

# app/blueprints/post_blueprint.rb
class PostBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :body, :published_at

  association :author, blueprint: UserBlueprint

  field :view_count do |post|
    post.views.count
  end

  view :detailed do
    association :comments, blueprint: CommentBlueprint
    field :related_posts do |post|
      PostBlueprint.render_as_json(post.related_posts)
    end
  end
end

# Controller usage:
class Api::V1::PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    render json: PostBlueprint.render(@post, view: :detailed)
  end
end
```

**JSONAPI::Serializer (JSON:API Spec):**
```ruby
# Gemfile
gem 'jsonapi-serializer'

# app/serializers/post_serializer.rb
class PostSerializer
  include JSONAPI::Serializer

  attributes :title, :body, :published_at

  belongs_to :author
  has_many :comments

  attribute :view_count do |post|
    post.views.count
  end
end

# Response format (JSON:API spec):
# {
#   "data": {
#     "id": "1",
#     "type": "post",
#     "attributes": {
#       "title": "My Post",
#       "body": "Content",
#       "view_count": 42
#     },
#     "relationships": {
#       "author": { "data": { "id": "5", "type": "user" } }
#     }
#   }
# }
```

**When to Use:**
- ActiveModel::Serializer: Standard use cases, good conventions
- Blueprinter: High-performance requirements (25x faster)
- JSONAPI::Serializer: JSON:API spec compliance needed

---

## Error Handling

### Standardized Error Responses

**Good Example:**
```ruby
# app/controllers/concerns/api_error_handler.rb
module ApiErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from StandardError, with: :internal_server_error
  end

  private

  def record_not_found(exception)
    render json: {
      error: {
        type: 'RecordNotFound',
        message: exception.message,
        status: 404
      }
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      error: {
        type: 'ValidationError',
        message: 'Validation failed',
        details: exception.record.errors.full_messages,
        status: 422
      }
    }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: {
      error: {
        type: 'ParameterMissing',
        message: exception.message,
        status: 400
      }
    }, status: :bad_request
  end

  def internal_server_error(exception)
    Rails.logger.error("Internal Server Error: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n"))

    render json: {
      error: {
        type: 'InternalServerError',
        message: 'An unexpected error occurred',
        status: 500
      }
    }, status: :internal_server_error
  end
end

# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  include ApiErrorHandler
end
```

**When to Use:**
- All API applications
- Consistent error format across endpoints
- Client-friendly error messages

---

## Rate Limiting

### Rack::Attack Configuration

**Good Example:**
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle all requests by IP (5rpm)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Throttle POST requests to /api/v1/posts by IP address
  throttle('posts/ip', limit: 5, period: 1.minute) do |req|
    if req.path == '/api/v1/posts' && req.post?
      req.ip
    end
  end

  # Throttle by authenticated user
  throttle('authenticated/user', limit: 1000, period: 1.hour) do |req|
    req.env['warden']&.user&.id
  end

  # Block suspicious requests
  blocklist('block bad actors') do |req|
    BadActor.where(ip_address: req.ip).exists?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Rate limit exceeded' }.to_json]
    ]
  end
end

# config/application.rb
config.middleware.use Rack::Attack
```

**When to Use:**
- Public APIs
- Preventing abuse
- Protecting expensive endpoints

---

## CORS Configuration

**Good Example:**
```ruby
# Gemfile
gem 'rack-cors'

# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3000').split(',')

    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 600
  end

  # Public endpoints with wider access
  allow do
    origins '*'

    resource '/api/v1/public/*',
      headers: :any,
      methods: [:get, :options, :head]
  end
end
```

**When to Use:**
- APIs consumed by browser-based clients
- Cross-origin requests needed
- Always for production APIs

---

## Complete API Example

```ruby
# app/controllers/api/v1/posts_controller.rb
module Api
  module V1
    class PostsController < BaseController
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :authenticate_user!, except: [:index, :show]

      # GET /api/v1/posts
      def index
        @pagy, @posts = pagy(
          Post.published.includes(:author),
          items: params[:per_page] || 25
        )

        render json: @posts,
               each_serializer: PostSerializer,
               meta: pagy_metadata(@pagy)
      end

      # GET /api/v1/posts/:id
      def show
        render json: @post, serializer: PostSerializer
      end

      # POST /api/v1/posts
      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: @post,
                 serializer: PostSerializer,
                 status: :created,
                 location: api_v1_post_url(@post)
        else
          render json: { errors: @post.errors },
                 status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/posts/:id
      def update
        if @post.update(post_params)
          render json: @post, serializer: PostSerializer
        else
          render json: { errors: @post.errors },
                 status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def post_params
        params.require(:post).permit(:title, :body, :published)
      end
    end
  end
end
```
