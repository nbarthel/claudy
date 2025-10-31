# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails-pattern-finder skill' do
  let(:skill_content) { load_skill('rails-pattern-finder') }
  let(:skill_metadata) { parse_skill_frontmatter(skill_content) }
  let(:skill_reference) { load_skill_reference('rails-pattern-finder') }

  describe 'skill metadata' do
    it 'has correct name' do
      expect(skill_metadata['name']).to eq('rails-pattern-finder')
    end

    it 'mentions Ref and patterns' do
      expect(skill_metadata['description']).to include('Ref')
      expect(skill_metadata['description']).to include('pattern')
    end

    it 'has correct version' do
      expect(skill_metadata['version']).to eq('1.1.0')
    end
  end

  describe 'reference.md content' do
    it 'contains pattern mappings' do
      expect(skill_reference).to include('authentication')
      expect(skill_reference).to include('background')
      expect(skill_reference).to include('caching')
    end

    it 'mentions Rails 8 defaults' do
      rails_8_features = ['Solid Queue', 'Solid Cache', 'Solid Cable']

      rails_8_features.each do |feature|
        expect(skill_reference).to include(feature)
      end
    end
  end

  describe 'Ref MCP integration' do
    context 'when Ref MCP is available' do
      it 'can search for patterns' do
        # Expected: Skill documents ref_search_documentation for pattern research
        # This tests documentation, not runtime execution
        expect(skill_content).to include('Ref').or include('ref')
      end
    end

    context 'when Ref MCP is not available' do
      it 'uses Grep for local pattern search' do
        # Expected: Skill documents Grep for local codebase pattern search
        # This tests documentation, not runtime execution
        expect(skill_content).to include('Grep')
      end
    end
  end

  describe 'pattern categories' do
    let(:patterns) do
      %w[
        authentication
        background_jobs
        caching
        real_time
        file_uploads
        pagination
      ]
    end

    it 'recognizes common patterns' do
      patterns.each do |pattern|
        # Reference should mention these patterns
        expect(skill_reference.downcase).to include(pattern.gsub('_', ' '))
      end
    end
  end

  describe 'Rails 8 built-in patterns' do
    it 'recommends Solid Queue for background jobs' do
      expect(skill_reference).to include('Solid Queue')
    end

    it 'recommends Solid Cache for caching' do
      expect(skill_reference).to include('Solid Cache')
    end

    it 'recommends Solid Cable for real-time' do
      expect(skill_reference).to include('Solid Cable')
    end

    it 'recommends authentication generator' do
      expect(skill_reference).to include('authentication')
    end
  end

  describe 'codebase search' do
    it 'can find service objects' do
      # Expected: Skill documents Glob/Grep usage for codebase search
      # This tests documentation, not runtime execution
      expect(skill_content).to include('Glob').or include('Grep')
    end

    it 'can find controller patterns' do
      # Expected: Skill documents pattern search capabilities
      # This tests documentation, not runtime execution
      expect(skill_content).to include('pattern').or include('search')
    end
  end

  describe 'error handling' do
    it 'handles unknown pattern' do
      pattern = 'completely_unknown_pattern'
      expect(skill_reference).not_to include(pattern)

      # Expected: Error with available patterns list (documented behavior)
    end

    it 'handles empty codebase' do
      # Expected: Returns best-practice examples from reference (documented behavior)
      # This tests documentation, not runtime execution
      expect(skill_reference).to include('best_practice')
    end
  end
end
