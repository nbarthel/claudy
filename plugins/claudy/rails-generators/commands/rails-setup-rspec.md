# rails-setup-rspec

Set up RSpec testing framework in a Rails application

---

Configure RSpec as the testing framework for this Rails application:

1. **Add RSpec gems** to Gemfile (rspec-rails, factory_bot_rails, faker, shoulda-matchers)
2. **Run bundle install**
3. **Generate RSpec configuration** with `rails generate rspec:install`
4. **Configure RSpec** in `spec/rails_helper.rb`:
   - Include FactoryBot methods
   - Configure Shoulda Matchers
   - Set up database cleaner if needed
   - Add helpful configurations
5. **Create spec directory structure**:
   - spec/models
   - spec/controllers
   - spec/requests
   - spec/system
   - spec/factories
6. **Add a sample test** to verify setup
7. **Update .gitignore** if needed
8. **Remove test/ directory** if present (ask first!)

Configuration recommendations:

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

Gems to add:

```ruby
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'selenium-webdriver'
end
```
