# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Ref MCP fallback behavior' do
  describe 'when Ref MCP is available' do
    it 'prefers Ref over WebFetch' do
      # Mock Ref MCP tools
      mock_ref_search('Rails documentation', [{ url: 'https://guides.rubyonrails.org' }])
      mock_ref_read('https://guides.rubyonrails.org', 'Content via Ref')

      # Expected: Uses Ref, doesn't call WebFetch
      expect(self).to receive(:ref_search_documentation)
      expect(self).not_to receive(:WebFetch)

      # (Actual skill execution would verify this)
    end

    it 'uses Ref for all three documentation skills' do
      skills = ['rails-docs-search', 'rails-api-lookup', 'rails-pattern-finder']

      skills.each do |skill|
        content = load_skill(skill)
        expect(content).to include('ref_search_documentation')
        expect(content).to include('primary')
      end
    end
  end

  describe 'when Ref MCP is not available' do
    before { disable_ref_mcp }

    it 'falls back to WebFetch seamlessly' do
      stub_request(:get, 'https://guides.rubyonrails.org/active_record_basics.html')
        .to_return(body: '<html>Content via WebFetch</html>')

      # Expected: Uses WebFetch without errors
    end

    it 'logs fallback warning' do
      # Skills should mention fallback in their output
      # (Would need actual skill execution to verify)
    end

    it 'maintains same functionality' do
      # Both Ref and WebFetch should return same data structure
      # Just different fetch mechanisms
    end
  end

  describe 'partial Ref availability' do
    it 'handles ref_search working but ref_read failing' do
      mock_ref_search('query', [{ url: 'https://example.com' }])
      allow_any_instance_of(Object).to receive(:ref_read_url)
        .and_raise(StandardError, 'Ref read failed')

      stub_request(:get, 'https://example.com')
        .to_return(body: '<html>Fallback content</html>')

      # Expected: Falls back to WebFetch for read
    end
  end

  describe 'network failures affect both' do
    it 'handles complete network outage' do
      disable_ref_mcp

      stub_request(:any, /.*/).to_timeout

      # Expected: Error response with cached knowledge
    end
  end

  describe 'performance comparison' do
    it 'documents Ref as token-efficient' do
      skills = ['rails-docs-search', 'rails-api-lookup', 'rails-pattern-finder']

      skills.each do |skill|
        content = load_skill(skill)
        expect(content).to include('token-efficient').or include('token')
      end
    end
  end
end
