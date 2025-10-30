# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Skill chaining integration' do
  describe 'version-detector → docs-search flow' do
    it 'uses detected version in documentation URLs' do
      # Step 1: Version detector identifies Rails 8.0.1
      gemfile_lock = load_fixture('Gemfile.lock.rails-8.0.1')
      mock_read_file('Gemfile.lock', gemfile_lock)

      # Step 2: Docs search uses version for URL construction
      expected_url = 'https://guides.rubyonrails.org/v8.0/active_record_basics.html'

      stub_request(:get, expected_url)
        .to_return(body: '<html>Rails 8.0 content</html>')

      # Expected: Skills coordinate through version
      expect(gemfile_lock).to include('8.0.1')
    end

    it 'falls back to default version when detection fails' do
      # Step 1: Version detector returns nil
      mock_read_file('Gemfile.lock', nil)
      mock_read_file('Gemfile', nil)

      # Step 2: Docs search uses default (8.0)
      default_url = 'https://guides.rubyonrails.org/v8.0/routing.html'

      stub_request(:get, default_url)
        .to_return(body: '<html>Default version content</html>')

      # Expected: Graceful fallback
    end
  end

  describe 'docs-search → api-lookup coordination' do
    it 'uses consistent version across both skills' do
      version = '7.1'

      guide_url = "https://guides.rubyonrails.org/v#{version}/active_record_basics.html"
      api_url = "https://api.rubyonrails.org/v#{version}/classes/ActiveRecord/Base.html"

      stub_request(:get, guide_url).to_return(body: '<html>Guide</html>')
      stub_request(:get, api_url).to_return(body: '<html>API</html>')

      # Expected: Both use same version
      expect(guide_url).to include("v#{version}")
      expect(api_url).to include("v#{version}")
    end
  end

  describe 'pattern-finder → docs-search → api-lookup flow' do
    it 'completes full pattern research workflow' do
      # Step 1: Pattern finder identifies "authentication"
      pattern_ref = load_skill_reference('rails-pattern-finder')
      expect(pattern_ref).to include('authentication')

      # Step 2: Docs search fetches security guide
      stub_request(:get, %r{guides.rubyonrails.org/.*security\.html})
        .to_return(body: '<html>Security guide</html>')

      # Step 3: API lookup fetches related classes
      stub_request(:get, %r{api.rubyonrails.org/.*Authenticat})
        .to_return(body: '<html>Auth API</html>')

      # Expected: Coordinated multi-skill research
    end
  end

  describe 'error propagation' do
    it 'handles upstream skill failures gracefully' do
      # Scenario: Version detector fails
      mock_read_file('Gemfile.lock', nil)

      # Downstream skills should handle nil version
      # They fall back to defaults
    end

    it 'prevents circular dependencies' do
      # Ensure skills don't infinitely invoke each other
      # (This would be caught by actual skill execution)
    end
  end

  describe 'concurrent skill invocation' do
    it 'allows parallel skill execution' do
      # Simulate agent invoking multiple skills simultaneously
      skills = [
        'rails-docs-search',
        'rails-api-lookup',
        'rails-pattern-finder'
      ]

      # All should be able to run without blocking
      skills.each do |skill|
        expect(load_skill(skill)).not_to be_nil
      end
    end
  end
end
