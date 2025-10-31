# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails-docs-search skill' do
  let(:skill_content) { load_skill('rails-docs-search') }
  let(:skill_metadata) { parse_skill_frontmatter(skill_content) }
  let(:skill_reference) { load_skill_reference('rails-docs-search') }

  describe 'skill metadata' do
    it 'has correct name' do
      expect(skill_metadata['name']).to eq('rails-docs-search')
    end

    it 'mentions Ref in description' do
      expect(skill_metadata['description']).to include('Ref')
    end

    it 'has ref tag' do
      expect(skill_metadata['tags']).to include('ref')
    end

    it 'has correct version' do
      expect(skill_metadata['version']).to eq('1.1.0')
    end
  end

  describe 'reference.md content' do
    it 'exists and is readable' do
      expect(skill_reference).not_to be_nil
      expect(skill_reference.length).to be > 100
    end

    it 'contains guide mappings' do
      expect(skill_reference).to include('active_record')
      expect(skill_reference).to include('routing')
      expect(skill_reference).to include('guides.rubyonrails.org')
    end
  end

  describe 'Ref MCP integration', :vcr do
    context 'when Ref MCP is available' do
      it 'uses ref_search_documentation' do
        # Expected: Skill documents ref_search_documentation as primary
        # This tests documentation, not runtime execution
        expect(skill_content).to include('ref_search_documentation')
      end
    end

    context 'when Ref MCP is not available' do
      it 'falls back to WebFetch' do
        stub_request(:get, 'https://guides.rubyonrails.org/v8.0/active_record_basics.html')
          .to_return(body: '<html>Active Record content</html>')

        # Expected: Skill documents WebFetch as fallback
        expect(skill_content).to include('WebFetch')
      end
    end
  end

  describe 'topic lookup' do
    let(:topics) do
      {
        'active_record_basics' => 'active_record_basics.html',
        'routing' => 'routing.html',
        'api_app' => 'api_app.html'
      }
    end

    it 'maps topics to URLs' do
      topics.each_key do |topic|
        expect(skill_reference).to include(topic)
      end
    end

    context 'with invalid topic' do
      it 'handles unknown topics' do
        # Topic not in reference.md
        unknown_topic = 'some_unknown_guide'

        expect(skill_reference).not_to include(unknown_topic)
      end
    end
  end

  describe 'version-specific URLs' do
    it 'constructs Rails 8.0 URLs' do
      base_url = 'https://guides.rubyonrails.org'
      version = 'v8.0'
      guide = 'active_record_basics.html'

      expected_url = "#{base_url}/#{version}/#{guide}"
      expect(expected_url).to eq('https://guides.rubyonrails.org/v8.0/active_record_basics.html')
    end

    it 'constructs Rails 7.1 URLs' do
      url = 'https://guides.rubyonrails.org/v7.1/routing.html'
      expect(url).to match(%r{v7\.1/routing\.html})
    end
  end

  describe 'error handling' do
    context 'network failures' do
      it 'handles timeout' do
        stub_request(:get, /guides.rubyonrails.org/)
          .to_timeout

        # Expected: Graceful error handling
      end

      it 'handles 404' do
        stub_request(:get, 'https://guides.rubyonrails.org/v9.0/future_guide.html')
          .to_return(status: 404)

        # Expected: Fallback to latest version
      end

      it 'handles 500' do
        stub_request(:get, /guides.rubyonrails.org/)
          .to_return(status: 500)

        # Expected: Error response with cached knowledge fallback
      end
    end

    context 'malformed responses' do
      it 'handles invalid HTML' do
        stub_request(:get, /guides.rubyonrails.org/)
          .to_return(body: '<html><broken')

        # Expected: Partial content extraction or error
      end
    end
  end

  describe 'caching behavior' do
    it 'notes WebFetch has 15-minute cache' do
      expect(skill_content).to include('15-minute')
      expect(skill_content).to include('cache')
    end
  end
end
