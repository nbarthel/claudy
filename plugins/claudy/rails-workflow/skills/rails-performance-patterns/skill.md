---
name: rails-performance-patterns
description: Detects N+1 queries, suggests eager loading, and recommends database indexes
auto_invoke: true
trigger_on: [file_modify]
file_patterns: ["**/models/**/*.rb", "**/controllers/**/*.rb"]
tags: [rails, performance, optimization, n+1, eager-loading, indexes]
priority: 2
version: 2.0
---

# Rails Performance Patterns Skill

Automatically detects performance issues and suggests optimizations.

## What This Skill Does

**Automatic Detection:**
- N+1 query problems (missing eager loading)
- Missing database indexes on foreign keys
- Inefficient query patterns
- Large result sets without pagination

**When It Activates:**
- Model files with associations modified
- Controller actions that query models
- Iteration over associations detected

## Key Checks

### 1. N+1 Query Detection

**Problem Pattern:**
```ruby
# app/controllers/posts_controller.rb
def index
  @posts = Post.all  # 1 query
  @posts.each do |post|
    puts post.author.name  # N queries (one per post)
  end
end
```

**Skill Output:**
```
⚠️  Performance: Potential N+1 query
Location: app/controllers/posts_controller.rb:15
Issue: Accessing 'author' association in loop without eager loading

Fix: Add includes to eager load:
@posts = Post.includes(:author).all
```

**Solution:**
```ruby
def index
  @posts = Post.includes(:author).all  # 2 queries total
end
```

### 2. Missing Indexes

**Checks:**
- Foreign keys have indexes
- Commonly queried columns indexed
- Unique constraints have indexes

**Example:**
```ruby
# db/migrate/xxx_create_posts.rb
create_table :posts do |t|
  t.references :user  # ✅ Auto-creates index
  t.string :slug      # ❌ Missing index if queried often
end
```

**Skill Output:**
```
⚠️  Performance: Missing index recommendation
Location: app/models/post.rb:5
Issue: slug column used in where clauses without index

Add migration:
add_index :posts, :slug, unique: true
```

### 3. Pagination Missing

**Problem:**
```ruby
def index
  @products = Product.all  # ❌ Loads all 100k+ products
end
```

**Skill Output:**
```
⚠️  Performance: Large result set without pagination
Location: app/controllers/products_controller.rb:10
Issue: Loading all Product records (estimated 100k+ rows)

Recommendation: Add pagination
# Use kaminari or pagy
@products = Product.page(params[:page]).per(20)
```

### 4. Counter Cache Opportunities

**Pattern:**
```ruby
# Without counter cache
@user.posts.count  # Runs COUNT(*) query every time

# With counter cache
@user.posts_count  # Reads from cached column
```

**Skill Output:**
```
ℹ️  Performance: Counter cache opportunity
Location: app/views/users/show.html.erb:12
Pattern: Frequently accessing post count

Add to migration:
add_column :users, :posts_count, :integer, default: 0

Update association:
belongs_to :user, counter_cache: true
```

## Configuration

```yaml
# .rails-performance.yml
n1_detection:
  enabled: true
  severity: warning

indexes:
  check_foreign_keys: true
  check_query_columns: true

pagination:
  warn_threshold: 1000
  require_for_large_tables: true

counter_cache:
  suggest_threshold: 3  # Suggest if accessed 3+ times
```

## Monitoring Integration

**Add instrumentation:**
```ruby
# config/initializers/query_monitoring.rb
ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if event.duration > 100  # Log slow queries
    Rails.logger.warn("Slow query (#{event.duration}ms): #{event.payload[:sql]}")
  end
end
```

## Common Optimizations

**Eager Loading:**
```ruby
# N+1
Post.all.each { |p| p.author.name }

# Fixed: includes (left join)
Post.includes(:author).each { |p| p.author.name }

# Fixed: preload (separate queries)
Post.preload(:author).each { |p| p.author.name }

# Fixed: eager_load (always joins)
Post.eager_load(:author).each { |p| p.author.name }
```

**Select Specific Columns:**
```ruby
# Loads all columns
Post.all

# Loads only needed columns
Post.select(:id, :title, :created_at)
```

**Batch Processing:**
```ruby
# Loads all at once
Post.all.each { |p| process(p) }

# Loads in batches of 1000
Post.find_each(batch_size: 1000) { |p| process(p) }
```

## References

- **Rails Performance Guide**: https://guides.rubyonrails.org/performance_testing.html
- **Bullet Gem**: https://github.com/flyerhzm/bullet
- **Pattern Library**: /patterns/caching-patterns.md

---

**This skill helps you build fast Rails applications from the start.**
