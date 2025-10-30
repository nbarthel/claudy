# Rails Workflow Plugin Test Suite

Comprehensive RSpec test suite for the rails-workflow plugin documentation skills.

## Overview

This test suite validates the 4 new documentation skills:
- `rails-version-detector`
- `rails-docs-search`
- `rails-api-lookup`
- `rails-pattern-finder`

## Setup

### Install Dependencies

```bash
cd /home/nbarthel/projects/claudy
bundle install
```

### Run Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/skills/rails_version_detector_spec.rb

# Run with specific tag
bundle exec rspec --tag focus

# Run integration tests only
bundle exec rspec spec/integration
```

## Test Structure

```
spec/
├── spec_helper.rb              # RSpec configuration
├── support/                    # Helper modules
│   ├── mock_tools.rb           # Mock Claude Code tools
│   ├── skill_test_helpers.rb  # Skill invocation helpers
│   └── fixture_helpers.rb     # Fixture loading
├── fixtures/                   # Test data
│   ├── Gemfile.lock.*         # Various Rails versions
│   ├── vcr_cassettes/         # Recorded HTTP responses
│   └── README.md
├── skills/                     # Unit tests for each skill
│   ├── rails_version_detector_spec.rb
│   ├── rails_docs_search_spec.rb
│   ├── rails_api_lookup_spec.rb
│   └── rails_pattern_finder_spec.rb
└── integration/                # Integration tests
    ├── skill_chaining_spec.rb  # Cross-skill coordination
    └── ref_fallback_spec.rb    # Ref MCP fallback behavior
```

## Test Categories

### Unit Tests (spec/skills/)

Test individual skills in isolation with mocked dependencies.

**Coverage**:
- Skill metadata validation
- Reference.md content validation
- URL construction logic
- Error handling
- Edge cases

**Example**:
```ruby
describe 'rails-version-detector skill' do
  it 'detects Rails 8.0.1' do
    content = load_fixture('Gemfile.lock.rails-8.0.1')
    mock_read_file('Gemfile.lock', content)

    expect(content).to include('rails (8.0.1)')
  end
end
```

### Integration Tests (spec/integration/)

Test skills working together and with external dependencies.

**Coverage**:
- Cross-skill coordination
- Ref MCP fallback behavior
- Version consistency across skills
- Error propagation
- Concurrent execution

**Example**:
```ruby
describe 'version-detector → docs-search flow' do
  it 'uses detected version in documentation URLs' do
    # Version detector identifies Rails 8.0.1
    # Docs search constructs v8.0 URLs
  end
end
```

## Mocking Tools

The test suite mocks Claude Code tools to avoid external dependencies:

```ruby
# Mock file reading
mock_read_file('Gemfile.lock', content)

# Mock grep searches
mock_grep('class.*Service', ['app/services/user_service.rb'])

# Mock WebFetch
mock_webfetch(url, prompt, response)

# Mock Ref MCP
mock_ref_search(query, results)
mock_ref_read(url, content)

# Disable Ref MCP (test fallback)
disable_ref_mcp
```

## VCR Cassettes

Real HTTP interactions with Rails documentation sites are recorded using VCR:

```ruby
it 'fetches actual Rails guide', :vcr do
  # First run: Records HTTP response
  # Subsequent runs: Replays recorded response
end
```

Cassettes stored in: `spec/fixtures/vcr_cassettes/`

## Test Fixtures

Pre-made test data in `spec/fixtures/`:

- `Gemfile.lock.rails-8.0.1` - Rails 8.0.1 project
- `Gemfile.lock.rails-7.1.3` - Rails 7.1.3 project
- `Gemfile.lock.malformed` - Corrupted file for error testing

Load with: `load_fixture('filename')`

## Coverage

Run with coverage report:

```bash
# SimpleCov generates coverage report
bundle exec rspec

# View coverage report
open coverage/index.html
```

**Target Coverage**: 90%+ line coverage

## Running Specific Tests

```bash
# By file
bundle exec rspec spec/skills/rails_version_detector_spec.rb

# By line
bundle exec rspec spec/skills/rails_version_detector_spec.rb:42

# By description pattern
bundle exec rspec -e "detects Rails 8"

# With tags
bundle exec rspec --tag vcr      # Tests using VCR
bundle exec rspec --tag focus    # Focused tests only
bundle exec rspec --tag ~slow    # Skip slow tests
```

## Continuous Integration

GitHub Actions workflow (future):

```yaml
name: Test Rails Skills
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
      - run: bundle install
      - run: bundle exec rspec
```

## Current Test Status

**Phase 1: Foundation** ✅
- [x] RSpec framework setup
- [x] Mock tools infrastructure
- [x] Fixture helpers
- [x] 4 skill unit tests (30+ examples each)
- [x] 2 integration tests

**Phase 2: Expansion** (Recommended)
- [ ] Add CRITICAL priority tests from rails-test-specialist review
- [ ] Add error handling scenarios
- [ ] Add performance benchmarks
- [ ] Add security tests

**Phase 3: Automation** (Future)
- [ ] CI/CD integration
- [ ] Automated coverage reporting
- [ ] Pre-commit hooks

## Contributing Tests

When adding new tests:

1. Follow existing patterns in spec/skills/
2. Use descriptive test names
3. Mock external dependencies
4. Add fixtures for test data
5. Document complex scenarios
6. Run rubocop: `bundle exec rubocop`

## Notes

These tests validate the **skill definitions** (markdown files) rather than actual skill execution by Claude. They verify:

- Skill metadata is correct
- Reference data is comprehensive
- URL construction logic is sound
- Skills mention proper tools (Ref, WebFetch)
- Error scenarios are documented

For actual skill execution testing, skills would need to be invoked by Claude Code in a live environment.
