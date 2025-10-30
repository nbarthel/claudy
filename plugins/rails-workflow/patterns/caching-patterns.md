# Rails Caching Patterns Guide

Comprehensive patterns for implementing effective caching strategies in Rails APIs.

---

## Table of Contents

1. [Fragment Caching](#fragment-caching)
2. [Low-Level Caching](#low-level-caching)
3. [HTTP Caching](#http-caching)
4. [Russian Doll Caching](#russian-doll-caching)
5. [Cache Invalidation](#cache-invalidation)
6. [Redis Configuration](#redis-configuration)
7. [Cache Warming](#cache-warming)

---

## Fragment Caching

### Basic Fragment Caching

**Good Example:**
```ruby
# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    namespace: 'myapp',
    expires_in: 1.hour
  }
end

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  def index
    @posts = Rails.cache.fetch('posts/index', expires_in: 5.minutes) do
      Post.published.includes(:author).order(created_at: :desc).to_a
    end

    render json: @posts, each_serializer: PostSerializer
  end

  def show
    @post = Rails.cache.fetch(['post', params[:id]], expires_in: 1.hour) do
      Post.includes(:author, :comments).find(params[:id])
    end

    render json: @post, serializer: PostSerializer
  end
end
```

### Cache Keys with Dependencies

**Good Example:**
```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    # Cache key includes updated_at timestamp
    cache_key = ['post', @post.id, @post.updated_at.to_i]

    json = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      PostSerializer.new(@post).to_json
    end

    render json: json
  end

  def index
    # Cache key includes max updated_at
    latest_update = Post.maximum(:updated_at)
    cache_key = ['posts', 'index', latest_update.to_i, params[:page]]

    posts = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      Post.published
          .page(params[:page])
          .includes(:author)
          .to_a
    end

    render json: posts, each_serializer: PostSerializer
  end
end
```

**When to Use:**
- Expensive database queries
- Serialized JSON responses
- Rendered views/partials
- API responses with low write frequency

---

## Low-Level Caching

### Rails.cache Operations

**Good Example:**
```ruby
# app/services/statistics_service.rb
class StatisticsService
  CACHE_TTL = 15.minutes

  def self.user_count
    Rails.cache.fetch('stats/user_count', expires_in: CACHE_TTL) do
      User.count
    end
  end

  def self.revenue_today
    Rails.cache.fetch("stats/revenue/#{Date.current}", expires_in: 1.hour) do
      Order.where(created_at: Date.current.all_day).sum(:total)
    end
  end

  def self.popular_posts(limit: 10)
    cache_key = "stats/popular_posts/#{limit}"

    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      Post.published
          .order(views_count: :desc)
          .limit(limit)
          .pluck(:id, :title, :views_count)
    end
  end

  def self.clear_all
    Rails.cache.delete_matched('stats/*')
  end
end
```

### Cache Aside Pattern

**Good Example:**
```ruby
# app/services/user_profile_service.rb
class UserProfileService
  def self.fetch(user_id)
    cache_key = "user_profile/#{user_id}"

    # Try cache first
    cached = Rails.cache.read(cache_key)
    return cached if cached

    # Cache miss - fetch from database
    profile = build_profile(user_id)

    # Store in cache
    Rails.cache.write(cache_key, profile, expires_in: 1.hour)

    profile
  end

  def self.invalidate(user_id)
    Rails.cache.delete("user_profile/#{user_id}")
  end

  private

  def self.build_profile(user_id)
    user = User.includes(:posts, :followers).find(user_id)

    {
      id: user.id,
      name: user.name,
      email: user.email,
      posts_count: user.posts.count,
      followers_count: user.followers.count,
      created_at: user.created_at
    }
  end
end
```

### Write-Through Cache

**Good Example:**
```ruby
# app/services/settings_service.rb
class SettingsService
  def self.get(key)
    cache_key = "settings/#{key}"

    Rails.cache.fetch(cache_key) do
      Setting.find_by(key: key)&.value
    end
  end

  def self.set(key, value)
    cache_key = "settings/#{key}"

    # Write to database
    setting = Setting.find_or_initialize_by(key: key)
    setting.value = value
    setting.save!

    # Write to cache (write-through)
    Rails.cache.write(cache_key, value)

    value
  end

  def self.delete(key)
    cache_key = "settings/#{key}"

    # Delete from database
    Setting.find_by(key: key)&.destroy

    # Delete from cache
    Rails.cache.delete(cache_key)
  end
end
```

**When to Use:**
- Cache aside: Read-heavy workloads, expensive computations
- Write-through: Strong consistency required, simple data
- Low-level: Fine-grained control over caching

---

## HTTP Caching

### ETag and Conditional GET

**Good Example:**
```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])

    # Generate ETag based on post state
    if stale?(
      etag: @post,
      last_modified: @post.updated_at,
      public: true
    )
      render json: @post, serializer: PostSerializer
    end
    # Rails automatically returns 304 Not Modified if ETag matches
  end

  def index
    @posts = Post.published.includes(:author)

    # ETag based on collection
    if stale?(
      etag: [@posts, params[:page]],
      last_modified: @posts.maximum(:updated_at),
      public: true
    )
      render json: @posts, each_serializer: PostSerializer
    end
  end
end
```

### Cache-Control Headers

**Good Example:**
```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  def set_cache_headers(max_age: 5.minutes, public: true)
    expires_in max_age, public: public
  end

  def no_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
  end
end

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < BaseController
  before_action :set_cache_headers, only: [:index, :show]

  def index
    # Response cached by browsers and CDN for 5 minutes
    @posts = Post.published
    render json: @posts
  end

  def show
    # Response cached for 1 hour
    set_cache_headers(max_age: 1.hour, public: true)
    @post = Post.find(params[:id])
    render json: @post
  end

  def user_profile
    # Private user data - only browser cache
    set_cache_headers(max_age: 5.minutes, public: false)
    render json: current_user
  end

  def admin_data
    # Never cache sensitive data
    no_cache
    render json: AdminData.all
  end
end
```

**When to Use:**
- ETag: Check if resource changed (saves bandwidth)
- Cache-Control: Control browser/CDN caching
- Public cache: Non-authenticated endpoints
- Private cache: User-specific data

---

## Russian Doll Caching

### Nested Cache Dependencies

**Good Example:**
```ruby
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :author
  has_many :comments

  # Touch author when post changes
  belongs_to :author, touch: true

  def cache_key_with_version
    "#{cache_key}/#{cache_version}"
  end

  def cache_version
    [
      updated_at.to_i,
      comments.maximum(:updated_at)&.to_i || 0
    ].join('-')
  end
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post

  # Touch post when comment changes
  belongs_to :post, touch: true
end

# app/serializers/post_serializer.rb
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :created_at
  belongs_to :author
  has_many :comments

  # Cached serialization
  def self.cached(post)
    Rails.cache.fetch([post, 'serialized'], expires_in: 1.hour) do
      new(post).as_json
    end
  end
end

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  def show
    @post = Post.includes(:author, :comments).find(params[:id])

    json = Rails.cache.fetch([@post, 'full'], expires_in: 1.hour) do
      PostSerializer.cached(@post).to_json
    end

    render json: json
  end
end
```

**Nested Fragment Caching:**
```ruby
# app/serializers/post_with_comments_serializer.rb
class PostWithCommentsSerializer
  def initialize(post)
    @post = post
  end

  def as_json
    # Outer cache (post)
    Rails.cache.fetch([@post, 'with_comments'], expires_in: 1.hour) do
      {
        id: @post.id,
        title: @post.title,
        body: @post.body,
        author: author_json,
        comments: comments_json
      }
    end
  end

  private

  def author_json
    # Inner cache (author)
    Rails.cache.fetch([@post.author, 'json'], expires_in: 1.hour) do
      {
        id: @post.author.id,
        name: @post.author.name
      }
    end
  end

  def comments_json
    # Inner cache (each comment)
    @post.comments.map do |comment|
      Rails.cache.fetch([comment, 'json'], expires_in: 1.hour) do
        {
          id: comment.id,
          body: comment.body,
          created_at: comment.created_at
        }
      end
    end
  end
end
```

**When to Use:**
- Nested resources (posts with comments)
- Complex serializations
- High read-to-write ratio
- Incremental cache invalidation needed

---

## Cache Invalidation

### Time-Based Expiration

**Good Example:**
```ruby
# app/services/cache_service.rb
class CacheService
  # Short TTL for frequently changing data
  FAST_TTL = 1.minute

  # Medium TTL for moderately stable data
  MEDIUM_TTL = 15.minutes

  # Long TTL for rarely changing data
  LONG_TTL = 1.hour

  # Very long TTL for static content
  STATIC_TTL = 24.hours

  def self.fetch_with_ttl(key, ttl: MEDIUM_TTL, &block)
    Rails.cache.fetch(key, expires_in: ttl, &block)
  end
end

# Usage:
trending_posts = CacheService.fetch_with_ttl(
  'posts/trending',
  ttl: CacheService::FAST_TTL
) do
  Post.trending.limit(10)
end
```

### Event-Based Invalidation

**Good Example:**
```ruby
# app/models/concerns/cacheable.rb
module Cacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_cache, on: [:create, :update, :destroy]
  end

  def cache_key_prefix
    self.class.name.underscore
  end

  def clear_cache
    # Clear individual record cache
    Rails.cache.delete([cache_key_prefix, id])

    # Clear collection cache
    Rails.cache.delete_matched("#{cache_key_prefix}/index*")
    Rails.cache.delete_matched("#{cache_key_prefix}/list*")

    # Clear associated caches
    clear_associated_caches
  end

  def clear_associated_caches
    # Override in models to clear related caches
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  include Cacheable

  belongs_to :author

  private

  def clear_associated_caches
    # Clear author's posts cache
    Rails.cache.delete(['author', author_id, 'posts'])

    # Clear homepage cache
    Rails.cache.delete('homepage/recent_posts')
  end
end
```

### Sweeper Pattern

**Good Example:**
```ruby
# app/sweepers/post_sweeper.rb
class PostSweeper
  def self.sweep_post(post)
    # Clear post cache
    Rails.cache.delete(['post', post.id])
    Rails.cache.delete(['post', post.id, 'full'])

    # Clear index caches
    sweep_index

    # Clear related caches
    sweep_author(post.author)
    sweep_tags(post.tags)
  end

  def self.sweep_index
    Rails.cache.delete_matched('posts/index*')
    Rails.cache.delete('posts/recent')
    Rails.cache.delete('posts/popular')
  end

  def self.sweep_author(author)
    Rails.cache.delete(['author', author.id, 'posts'])
  end

  def self.sweep_tags(tags)
    tags.each do |tag|
      Rails.cache.delete(['tag', tag.id, 'posts'])
    end
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  after_commit :sweep_cache

  private

  def sweep_cache
    PostSweeper.sweep_post(self)
  end
end
```

**When to Use:**
- Time-based: Simple, predictable invalidation
- Event-based: Immediate consistency required
- Sweeper: Complex invalidation logic

---

## Redis Configuration

### Production Setup

**Good Example:**
```ruby
# config/initializers/redis.rb
REDIS_CONFIG = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  connect_timeout: 5,
  read_timeout: 1,
  write_timeout: 1,
  reconnect_attempts: 3,
  reconnect_delay: 0.5,
  reconnect_delay_max: 5
}

# Separate Redis instances for different purposes
$redis_cache = Redis.new(REDIS_CONFIG.merge(db: 0))
$redis_jobs = Redis.new(REDIS_CONFIG.merge(db: 1))
$redis_session = Redis.new(REDIS_CONFIG.merge(db: 2))

# Connection pool for thread safety
require 'connection_pool'

$redis_pool = ConnectionPool.new(size: 10, timeout: 5) do
  Redis.new(REDIS_CONFIG)
end

# config/environments/production.rb
Rails.application.configure do
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'],
    namespace: "myapp:#{Rails.env}",
    expires_in: 1.hour,
    connect_timeout: 5,
    read_timeout: 1,
    write_timeout: 1,
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.error("Redis error: #{exception.class} #{exception.message}")
      # Optionally send to error tracking
      Sentry.capture_exception(exception)
    }
  }
end
```

### Redis Fallback

**Good Example:**
```ruby
# app/services/resilient_cache_service.rb
class ResilientCacheService
  def self.fetch(key, fallback: nil, expires_in: 1.hour, &block)
    begin
      Rails.cache.fetch(key, expires_in: expires_in, &block)
    rescue Redis::BaseError => e
      Rails.logger.error("Cache error: #{e.message}")

      # Return fallback or execute block directly
      fallback || block.call
    end
  end

  def self.write(key, value, expires_in: 1.hour)
    Rails.cache.write(key, value, expires_in: expires_in)
  rescue Redis::BaseError => e
    Rails.logger.error("Cache write error: #{e.message}")
    nil
  end

  def self.delete(key)
    Rails.cache.delete(key)
  rescue Redis::BaseError => e
    Rails.logger.error("Cache delete error: #{e.message}")
    nil
  end
end
```

**When to Use:**
- Production: Always use connection pooling
- Error handling: Graceful degradation on Redis failure
- Multiple databases: Separate concerns (cache, jobs, sessions)

---

## Cache Warming

**Good Example:**
```ruby
# lib/tasks/cache.rake
namespace :cache do
  desc 'Warm up critical caches'
  task warm: :environment do
    puts "Warming up caches..."

    # Homepage data
    warm_homepage_cache

    # Popular posts
    warm_popular_posts

    # User statistics
    warm_statistics

    puts "Cache warming complete!"
  end

  def warm_homepage_cache
    puts "  - Homepage cache"
    Rails.cache.fetch('homepage/recent_posts', expires_in: 15.minutes) do
      Post.published.recent.limit(10).to_a
    end
  end

  def warm_popular_posts
    puts "  - Popular posts cache"
    Rails.cache.fetch('posts/popular', expires_in: 1.hour) do
      Post.popular.limit(20).to_a
    end
  end

  def warm_statistics
    puts "  - Statistics cache"
    %w[user_count post_count comment_count].each do |stat|
      StatisticsService.public_send(stat)
    end
  end
end

# app/jobs/cache_warming_job.rb
class CacheWarmingJob < ApplicationJob
  queue_as :low

  def perform
    # Warm critical caches during off-peak hours
    Rake::Task['cache:warm'].invoke
  end
end

# config/initializers/cache_warming.rb
if Rails.env.production?
  Rails.application.config.after_initialize do
    # Warm cache on startup
    CacheWarmingJob.set(wait: 30.seconds).perform_later
  end
end
```

**When to Use:**
- Application startup (avoid cold start)
- After deployments (repopulate cache)
- Scheduled (during off-peak hours)
- After bulk data changes
