# frozen_string_literal: true

require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'json'

# Configure RSpec
RSpec.configure do |config|
  # Use expect syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  # Mock with RSpec
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Shared context for all examples
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Filter run when focused
  config.filter_run_when_matching :focus

  # Randomize order
  config.order = :random
  Kernel.srand config.seed

  # Profile slowest examples
  config.profile_examples = 10

  # Warnings
  config.warnings = true

  # Output formatting
  config.default_formatter = 'doc' if config.files_to_run.one?
end

# Configure WebMock
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['rubyonrails.org', 'api.rubyonrails.org', 'guides.rubyonrails.org']
)

# Configure VCR for recording HTTP interactions
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }

  # Filter sensitive data
  config.filter_sensitive_data('<REDACTED>') { ENV['API_KEY'] }
end

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |f| require f }

puts "RSpec test suite for rails-workflow plugin"
puts "Ruby version: #{RUBY_VERSION}"
puts "RSpec version: #{RSpec::Version::STRING}"
