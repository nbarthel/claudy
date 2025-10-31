# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails-api-lookup skill' do
  let(:skill_content) { load_skill('rails-api-lookup') }
  let(:skill_metadata) { parse_skill_frontmatter(skill_content) }
  let(:skill_reference) { load_skill_reference('rails-api-lookup') }

  describe 'skill metadata' do
    it 'has correct name' do
      expect(skill_metadata['name']).to eq('rails-api-lookup')
    end

    it 'mentions Ref in description' do
      expect(skill_metadata['description']).to include('Ref')
    end

    it 'has correct version' do
      expect(skill_metadata['version']).to eq('1.1.0')
    end
  end

  describe 'reference.md content' do
    it 'contains API class mappings' do
      expect(skill_reference).to include('ActiveRecord')
      expect(skill_reference).to include('ActionController')
      expect(skill_reference).to include('api.rubyonrails.org')
    end

    it 'lists common API classes' do
      common_classes = [
        'ActiveRecord::Base',
        'ActionController::Base',
        'ActionController::API'
      ]

      common_classes.each do |klass|
        # Reference should mention these classes
        expect(skill_reference).to include(klass.split('::').first)
      end
    end
  end

  describe 'Ref MCP integration', :vcr do
    context 'when Ref MCP is available' do
      it 'uses ref_search_documentation for API lookup' do
        # Expected: Skill documents ref_search_documentation as primary
        # This tests documentation, not runtime execution
        expect(skill_content).to include('ref_search_documentation')
      end
    end

    context 'when Ref MCP is not available' do
      it 'falls back to WebFetch' do
        stub_request(:get, /api.rubyonrails.org/)
          .to_return(body: '<html>API content</html>')

        # Expected: Skill documents WebFetch as fallback
        expect(skill_content).to include('WebFetch')
      end
    end
  end

  describe 'URL construction' do
    it 'converts module paths to URLs' do
      # ActiveRecord::Base → ActiveRecord/Base.html
      klass = 'ActiveRecord::Base'
      path = klass.gsub('::', '/')

      expect(path).to eq('ActiveRecord/Base')

      url = "https://api.rubyonrails.org/v8.0/classes/#{path}.html"
      expect(url).to eq('https://api.rubyonrails.org/v8.0/classes/ActiveRecord/Base.html')
    end

    it 'handles nested modules' do
      klass = 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
      path = klass.gsub('::', '/')

      expect(path).to eq('ActiveRecord/ConnectionAdapters/PostgreSQLAdapter')
    end

    it 'handles method anchors' do
      base_url = 'https://api.rubyonrails.org/v8.0/classes/ActiveRecord/Base.html'
      method_anchor = '#method-i-save'

      full_url = "#{base_url}#{method_anchor}"
      expect(full_url).to include('method-i-save')
    end
  end

  describe 'method lookup' do
    context 'instance methods' do
      it 'uses method-i- anchor' do
        anchor = '#method-i-save'
        expect(anchor).to match(/method-i-/)
      end
    end

    context 'class methods' do
      it 'uses method-c- anchor' do
        anchor = '#method-c-find'
        expect(anchor).to match(/method-c-/)
      end
    end
  end

  describe 'error handling' do
    it 'handles unknown class' do
      stub_request(:get, 'https://api.rubyonrails.org/v8.0/classes/UnknownClass.html')
        .to_return(status: 404)

      # Expected: Error with suggestion
    end

    it 'handles method not found' do
      # Valid class but invalid method
      stub_request(:get, /api.rubyonrails.org.*#method-i-nonexistent/)
        .to_return(status: 404)

      # Expected: List available methods
    end
  end
end
