---
name: rails-test-patterns
description: Ensures comprehensive test coverage following Rails testing best practices
auto_invoke: true
trigger_on: [file_create, file_modify]
file_patterns: ["**/spec/**/*_spec.rb", "**/test/**/*_test.rb"]
tags: [rails, testing, rspec, minitest, coverage, tdd]
priority: 2
version: 2.0
---

# Rails Test Patterns Skill

Automatically ensures test quality and comprehensive coverage.

## What This Skill Does

**Automatic Checks:**
- Test framework detection (RSpec vs Minitest)
- AAA pattern (Arrange-Act-Assert)
- Coverage thresholds (80%+ models, 70%+ controllers)
- Factory usage over fixtures
- No flaky tests (sleep, Time.now without freezing)

**When It Activates:**
- Test files created or modified
- New models/controllers added (ensures tests exist)

## Test Quality Checks

### 1. AAA Pattern

**Good:**
```ruby
RSpec.describe User do
  describe '#full_name' do
    it 'combines first and last name' do
      # Arrange
      user = User.new(first_name: 'John', last_name: 'Doe')

      # Act
      result = user.full_name

      # Assert
      expect(result).to eq('John Doe')
    end
  end
end
```

**Skill Output (if violated):**
```
⚠️  Test Pattern: AAA structure not clear
Location: spec/models/user_spec.rb:15
Recommendation: Separate Arrange, Act, Assert with comments
```

### 2. Framework Detection

**Detects:**
```ruby
# RSpec
describe Model do
  it 'does something' do
    expect(value).to eq(expected)
  end
end

# Minitest
class ModelTest < ActiveSupport::TestCase
  test "does something" do
    assert_equal expected, value
  end
end
```

### 3. Factory Usage

**Preferred:**
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end

# In tests
user = create(:user)
```

**Skill Output:**
```
ℹ️  Test Pattern: Consider using FactoryBot
Location: spec/models/post_spec.rb:8
Current: User.create(name: 'Test', email: 'test@example.com')
Recommendation: Define factory and use create(:user)
```

### 4. Coverage Thresholds

**Checks:**
- Models: 80%+ coverage
- Controllers: 70%+ coverage
- Services: 90%+ coverage

**Skill Output:**
```
⚠️  Test Coverage: Below threshold
File: app/models/order.rb
Coverage: 65% (threshold: 80%)
Missing: #calculate_total, #apply_discount methods

Add tests for uncovered methods.
```

### 5. Flaky Test Detection

**Problem:**
```ruby
# BAD
it 'expires after 1 hour' do
  user = create(:user)
  sleep(3601)  # ❌ Actual waiting
  expect(user.expired?).to be true
end

# GOOD
it 'expires after 1 hour' do
  user = create(:user)
  travel 1.hour do  # ✅ Time travel
    expect(user.expired?).to be true
  end
end
```

**Skill Output:**
```
❌ Test Anti-pattern: Using sleep in test
Location: spec/models/session_spec.rb:42
Issue: sleep() makes tests slow and flaky

Fix: Use time helpers
travel 1.hour do
  # assertions here
end
```

## Test Types

### Model Tests

**Should test:**
- Validations
- Associations
- Scopes
- Instance methods
- Class methods

**Example:**
```ruby
RSpec.describe Post, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end

  describe '#published?' do
    it 'returns true when published_at is set' do
      post = build(:post, published_at: 1.day.ago)
      expect(post.published?).to be true
    end
  end
end
```

### Request Tests

**Should test:**
- HTTP status codes
- Response body content
- Authentication requirements
- Authorization checks

**Example:**
```ruby
RSpec.describe 'Posts API', type: :request do
  describe 'GET /api/v1/posts' do
    it 'returns all posts' do
      create_list(:post, 3)

      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/posts'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
```

## Configuration

```yaml
# .rails-testing.yml
coverage:
  models: 80
  controllers: 70
  services: 90

patterns:
  enforce_aaa: warning
  require_factories: info
  detect_flaky: error

framework:
  auto_detect: true
  prefer: rspec  # or minitest
```

## References

- **RSpec Best Practices**: https://rspec.info/
- **Minitest Guide**: https://github.com/minitest/minitest
- **FactoryBot**: https://github.com/thoughtbot/factory_bot
- **Pattern Library**: /patterns/testing-patterns.md

---

**This skill ensures your Rails app has comprehensive, maintainable test coverage.**
