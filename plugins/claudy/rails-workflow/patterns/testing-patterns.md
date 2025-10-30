# Rails Testing Patterns Guide

Comprehensive patterns for testing Rails applications with RSpec and Minitest.

---

## Table of Contents

1. [RSpec Configuration](#rspec-configuration)
2. [Model Testing](#model-testing)
3. [Controller Testing](#controller-testing)
4. [Request/Integration Testing](#requestintegration-testing)
5. [Service Object Testing](#service-object-testing)
6. [Factory Patterns](#factory-patterns)
7. [Test Coverage and CI](#test-coverage-and-ci)

---

## RSpec Configuration

### Setup and Best Practices

**Good Example:**
```ruby
# Gemfile (test group)
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'vcr'
end

# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("Running in production!") if Rails.env.production?

require 'rspec/rails'
require 'database_cleaner/active_record'

# Load support files
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Factory Bot
  config.include FactoryBot::Syntax::Methods

  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Spec types
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Disable external HTTP requests
  config.before(:each) do
    stub_request(:any, /.*/).to_raise(WebMock::NetConnectNotAllowedError)
  end

  # Allow VCR for specific examples
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description]
      .split(/\s+/, 2)
      .join("/")
      .tr(".", "/")
      .gsub(/[^\w\/]+/, "_")
      .gsub(/\/$/, "")

    VCR.use_cassette(name) do
      example.call
    end
  end
end

# spec/support/shoulda_matchers.rb
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# spec/support/api_helpers.rb
module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    token = user.generate_access_token
    { 'Authorization' => "Bearer #{token.token}" }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
```

**When to Use:**
- All Rails projects with RSpec
- API testing needs
- External API mocking required

---

## Model Testing

### Validations and Associations

**Good Example:**
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  # == Setup ================================================================
  let(:user) { build(:user) }

  # == Associations =========================================================
  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_one(:profile).dependent(:destroy) }
    it { should belong_to(:organization).optional }
  end

  # == Validations ==========================================================
  describe 'validations' do
    subject { user }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should have_secure_password }
    it { should validate_length_of(:password).is_at_least(8) }

    context 'email format' do
      it 'validates email format' do
        user.email = 'invalid-email'
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end

      it 'allows valid email' do
        user.email = 'user@example.com'
        expect(user).to be_valid
      end
    end
  end

  # == Scopes ===============================================================
  describe 'scopes' do
    describe '.active' do
      let!(:active_user) { create(:user, active: true) }
      let!(:inactive_user) { create(:user, active: false) }

      it 'returns only active users' do
        expect(User.active).to include(active_user)
        expect(User.active).not_to include(inactive_user)
      end
    end

    describe '.recent' do
      let!(:old_user) { create(:user, created_at: 1.year.ago) }
      let!(:recent_user) { create(:user, created_at: 1.day.ago) }

      it 'returns users created in last 30 days' do
        expect(User.recent).to include(recent_user)
        expect(User.recent).not_to include(old_user)
      end
    end
  end

  # == Instance Methods =====================================================
  describe '#full_name' do
    it 'returns first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end

  describe '#admin?' do
    it 'returns true for admin users' do
      admin = build(:user, :admin)
      expect(admin.admin?).to be true
    end

    it 'returns false for regular users' do
      expect(user.admin?).to be false
    end
  end

  # == Class Methods ========================================================
  describe '.find_by_email' do
    let!(:user) { create(:user, email: 'test@example.com') }

    it 'finds user by case-insensitive email' do
      expect(User.find_by_email('TEST@example.com')).to eq(user)
    end

    it 'returns nil if not found' do
      expect(User.find_by_email('nonexistent@example.com')).to be_nil
    end
  end

  # == Callbacks ============================================================
  describe 'callbacks' do
    describe 'before_create' do
      it 'generates API token' do
        user = build(:user, api_token: nil)
        user.save!
        expect(user.api_token).to be_present
      end
    end

    describe 'after_create' do
      it 'sends welcome email' do
        expect {
          create(:user)
        }.to have_enqueued_job(SendWelcomeEmailJob)
      end
    end
  end

  # == Complex Behavior =====================================================
  describe '#deactivate!' do
    let(:user) { create(:user, active: true) }

    it 'marks user as inactive' do
      user.deactivate!
      expect(user.reload.active).to be false
    end

    it 'cancels scheduled jobs' do
      user.deactivate!
      expect(user.scheduled_jobs).to be_empty
    end

    it 'logs deactivation' do
      expect {
        user.deactivate!
      }.to change { user.activity_logs.count }.by(1)
    end
  end
end
```

**When to Use:**
- All model files
- Test validations, associations, scopes, methods
- 80%+ coverage target

---

## Controller Testing

### API Controller Testing

**Good Example:**
```ruby
# spec/controllers/api/v1/posts_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, author: user) }

  before do
    # Stub authentication
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'GET #index' do
    let!(:posts) { create_list(:post, 3, :published) }

    it 'returns successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns all published posts' do
      get :index
      expect(json_response['data'].count).to eq(3)
    end

    it 'does not return unpublished posts' do
      create(:post, :draft)
      get :index
      expect(json_response['data'].count).to eq(3)
    end

    context 'with pagination' do
      before { create_list(:post, 30, :published) }

      it 'returns paginated results' do
        get :index, params: { page: 1, per_page: 10 }
        expect(json_response['data'].count).to eq(10)
        expect(json_response['meta']['total_pages']).to eq(4)
      end
    end
  end

  describe 'GET #show' do
    context 'when post exists' do
      it 'returns the post' do
        get :show, params: { id: post_record.id }
        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(post_record.id)
      end
    end

    context 'when post does not exist' do
      it 'returns not found' do
        get :show, params: { id: 'nonexistent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { post: { title: 'New Post', body: 'Content', published: true } }
    end

    context 'with valid params' do
      it 'creates new post' do
        expect {
          post :create, params: valid_params
        }.to change { Post.count }.by(1)
      end

      it 'returns created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'associates post with current user' do
        post :create, params: valid_params
        expect(Post.last.author).to eq(user)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { post: { title: '', body: 'Content' } }
      end

      it 'does not create post' do
        expect {
          post :create, params: invalid_params
        }.not_to change { Post.count }
      end

      it 'returns unprocessable entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post :create, params: invalid_params
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    let(:update_params) do
      { id: post_record.id, post: { title: 'Updated Title' } }
    end

    context 'when user owns the post' do
      it 'updates the post' do
        patch :update, params: update_params
        expect(post_record.reload.title).to eq('Updated Title')
      end

      it 'returns success' do
        patch :update, params: update_params
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user does not own the post' do
      let(:other_post) { create(:post) }

      it 'returns forbidden' do
        patch :update, params: { id: other_post.id, post: { title: 'Hacked' } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:post_to_delete) { create(:post, author: user) }

    it 'deletes the post' do
      expect {
        delete :destroy, params: { id: post_to_delete.id }
      }.to change { Post.count }.by(-1)
    end

    it 'returns no content' do
      delete :destroy, params: { id: post_to_delete.id }
      expect(response).to have_http_status(:no_content)
    end
  end
end
```

**When to Use:**
- All controller files
- Test each action (index, show, create, update, destroy)
- Test authorization and error cases

---

## Request/Integration Testing

**Good Example:**
```ruby
# spec/requests/api/v1/posts_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Posts', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/posts' do
    let!(:posts) { create_list(:post, 5, :published) }

    context 'when authenticated' do
      before { get '/api/v1/posts', headers: headers }

      it 'returns posts' do
        expect(json_response['data']).not_to be_empty
        expect(json_response['data'].size).to eq(5)
      end

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes pagination meta' do
        expect(json_response['meta']).to include(
          'current_page',
          'total_pages',
          'total_count'
        )
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get '/api/v1/posts'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with filtering' do
      let!(:ruby_post) { create(:post, :published, tags: ['ruby']) }
      let!(:js_post) { create(:post, :published, tags: ['javascript']) }

      it 'filters by tag' do
        get '/api/v1/posts', params: { tag: 'ruby' }, headers: headers
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'][0]['id']).to eq(ruby_post.id)
      end
    end

    context 'with sorting' do
      let!(:old_post) { create(:post, created_at: 1.day.ago) }
      let!(:new_post) { create(:post, created_at: 1.hour.ago) }

      it 'sorts by created_at desc' do
        get '/api/v1/posts', params: { sort: '-created_at' }, headers: headers
        ids = json_response['data'].map { |p| p['id'] }
        expect(ids.first).to eq(new_post.id)
      end
    end
  end

  describe 'POST /api/v1/posts' do
    let(:valid_params) do
      {
        post: {
          title: 'New Post',
          body: 'This is the content',
          published: true
        }
      }
    end

    context 'with valid params' do
      it 'creates a post' do
        expect {
          post '/api/v1/posts', params: valid_params, headers: headers
        }.to change { Post.count }.by(1)
      end

      it 'returns created status' do
        post '/api/v1/posts', params: valid_params, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'returns the created post' do
        post '/api/v1/posts', params: valid_params, headers: headers
        expect(json_response['title']).to eq('New Post')
      end

      it 'includes location header' do
        post '/api/v1/posts', params: valid_params, headers: headers
        expect(response.headers['Location']).to be_present
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { post: { title: '', body: 'No title' } }
      end

      it 'does not create a post' do
        expect {
          post '/api/v1/posts', params: invalid_params, headers: headers
        }.not_to change { Post.count }
      end

      it 'returns unprocessable entity' do
        post '/api/v1/posts', params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/api/v1/posts', params: invalid_params, headers: headers
        expect(json_response['errors']).to include('title')
      end
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    let(:post_record) { create(:post, author: user) }
    let(:update_params) do
      { post: { title: 'Updated Title' } }
    end

    it 'updates the post' do
      patch "/api/v1/posts/#{post_record.id}",
            params: update_params,
            headers: headers

      expect(post_record.reload.title).to eq('Updated Title')
    end

    it 'returns ok status' do
      patch "/api/v1/posts/#{post_record.id}",
            params: update_params,
            headers: headers

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    let!(:post_record) { create(:post, author: user) }

    it 'deletes the post' do
      expect {
        delete "/api/v1/posts/#{post_record.id}", headers: headers
      }.to change { Post.count }.by(-1)
    end

    it 'returns no content' do
      delete "/api/v1/posts/#{post_record.id}", headers: headers
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'Complex workflow' do
    it 'creates, updates, and deletes a post' do
      # Create
      post '/api/v1/posts',
           params: { post: { title: 'Test', body: 'Content' } },
           headers: headers

      expect(response).to have_http_status(:created)
      post_id = json_response['id']

      # Update
      patch "/api/v1/posts/#{post_id}",
            params: { post: { title: 'Updated' } },
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['title']).to eq('Updated')

      # Delete
      delete "/api/v1/posts/#{post_id}", headers: headers
      expect(response).to have_http_status(:no_content)

      # Verify deleted
      get "/api/v1/posts/#{post_id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
```

**When to Use:**
- End-to-end API testing
- Test complete request/response cycles
- Test authentication flows
- Integration between multiple endpoints

---

## Service Object Testing

**Good Example:**
```ruby
# spec/services/user_registration_service_spec.rb
require 'rails_helper'

RSpec.describe UserRegistrationService do
  describe '.call' do
    let(:params) do
      {
        email: 'user@example.com',
        password: 'password123',
        name: 'John Doe'
      }
    end

    subject(:service) { described_class.new(params) }

    context 'with valid params' do
      it 'creates a user' do
        expect {
          service.call
        }.to change { User.count }.by(1)
      end

      it 'sends welcome email' do
        expect {
          service.call
        }.to have_enqueued_job(SendWelcomeEmailJob)
      end

      it 'creates user profile' do
        user = service.call
        expect(user.profile).to be_present
      end

      it 'returns the user' do
        user = service.call
        expect(user).to be_a(User)
        expect(user.email).to eq('user@example.com')
      end

      it 'sets default preferences' do
        user = service.call
        expect(user.preferences['notifications']).to be true
      end
    end

    context 'with invalid params' do
      let(:params) { { email: 'invalid', password: 'short' } }

      it 'does not create user' do
        expect {
          service.call
        }.not_to change { User.count }
      end

      it 'raises validation error' do
        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when email already exists' do
      before { create(:user, email: params[:email]) }

      it 'raises error' do
        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with transaction rollback' do
      before do
        allow(SendWelcomeEmailJob).to receive(:perform_later)
          .and_raise(StandardError)
      end

      it 'rolls back user creation' do
        expect {
          service.call rescue nil
        }.not_to change { User.count }
      end
    end
  end
end
```

**When to Use:**
- All service objects
- Test success paths and error cases
- Test transaction behavior
- Test external dependencies (jobs, APIs)

---

## Factory Patterns

**Good Example:**
```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    password { 'password123' }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :with_posts do
      transient do
        posts_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:post, evaluator.posts_count, author: user)
      end
    end

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end
  end
end

# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    association :author, factory: :user

    trait :published do
      published { true }
      published_at { Time.current }
    end

    trait :draft do
      published { false }
      published_at { nil }
    end

    trait :with_comments do
      transient do
        comments_count { 3 }
      end

      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.comments_count, post: post)
      end
    end
  end
end

# Usage examples:
# create(:user)
# create(:user, :admin)
# create(:user, :with_posts, posts_count: 10)
# build(:post, :published)
# create(:post, :with_comments, comments_count: 5)
```

**When to Use:**
- All test data creation
- Use traits for variations
- Use transient attributes for counts
- Use associations for relationships

---

## Test Coverage and CI

### SimpleCov Configuration

**Good Example:**
```ruby
# spec/spec_helper.rb
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start 'rails' do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/vendor/'

    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Services', 'app/services'
    add_group 'Jobs', 'app/jobs'
    add_group 'Serializers', 'app/serializers'

    minimum_coverage 80
    minimum_coverage_by_file 70
  end
end
```

### GitHub Actions CI

**Good Example:**
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v3

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Setup database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load

      - name: Run tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379/0
          COVERAGE: true
        run: bundle exec rspec

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/.resultset.json
```

**When to Use:**
- All projects
- 80%+ coverage target
- CI/CD pipelines
- Automated testing on PRs
