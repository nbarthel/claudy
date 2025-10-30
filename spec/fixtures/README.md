# Test Fixtures

This directory contains test fixtures for the rails-workflow plugin test suite.

## Gemfile.lock Fixtures

- `Gemfile.lock.rails-8.0.1` - Rails 8.0.1 project
- `Gemfile.lock.rails-7.1.3` - Rails 7.1.3 project
- `Gemfile.lock.malformed` - Corrupted Gemfile.lock for error testing

## VCR Cassettes

The `vcr_cassettes/` directory contains recorded HTTP interactions with:
- guides.rubyonrails.org
- api.rubyonrails.org

These are used to replay HTTP responses without hitting the actual servers during tests.

## Adding New Fixtures

To add a new fixture:
1. Create the file in this directory
2. Use descriptive filename (e.g., `Gemfile.lock.rails-9.0.0.beta1`)
3. Load it in tests using `load_fixture('filename')`
