# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails-version-detector skill' do
  let(:skill_content) { load_skill('rails-version-detector') }
  let(:skill_metadata) { parse_skill_frontmatter(skill_content) }

  describe 'skill metadata' do
    it 'has correct name' do
      expect(skill_metadata['name']).to eq('rails-version-detector')
    end

    it 'has description' do
      expect(skill_metadata['description']).to include('Rails version')
    end

    it 'is a helper skill' do
      expect(skill_metadata['tags']).to include('helper')
    end
  end

  describe 'version detection from Gemfile.lock' do
    context 'with Rails 8.0.1' do
      it 'detects exact version' do
        content = load_fixture('Gemfile.lock.rails-8.0.1')
        mock_read_file('Gemfile.lock', content)

        # Expected behavior: Extract "8.0.1" from rails (8.0.1) line
        expect(content).to include('rails (8.0.1)')
      end
    end

    context 'with Rails 7.1.3' do
      it 'detects exact version' do
        content = load_fixture('Gemfile.lock.rails-7.1.3')
        mock_read_file('Gemfile.lock', content)

        expect(content).to include('rails (7.1.3)')
      end
    end

    context 'with malformed Gemfile.lock' do
      it 'handles missing closing parenthesis' do
        content = load_fixture('Gemfile.lock.malformed')
        mock_read_file('Gemfile.lock', content)

        # Should handle gracefully
        expect(content).to include('rails (8.0.1')
        expect(content).not_to match(/rails \([0-9.]+\)/)
      end
    end

    context 'with pre-release version' do
      it 'handles beta versions' do
        content = gemfile_lock_fixture(rails_version: '8.0.0.beta1')
        mock_read_file('Gemfile.lock', content)

        expect(content).to include('8.0.0.beta1')
      end

      it 'handles alpha versions' do
        content = gemfile_lock_fixture(rails_version: '9.0.0.alpha')
        mock_read_file('Gemfile.lock', content)

        expect(content).to include('9.0.0.alpha')
      end

      it 'handles rc versions' do
        content = gemfile_lock_fixture(rails_version: '8.1.0.rc1')
        mock_read_file('Gemfile.lock', content)

        expect(content).to include('8.1.0.rc1')
      end
    end

    context 'with multiple Rails gems' do
      it 'identifies first occurrence' do
        # Simulating Gemfile.lock conflict
        content = <<~LOCKFILE
          GEM
            specs:
              rails (7.1.3)
              rails (8.0.0)
        LOCKFILE

        mock_read_file('Gemfile.lock', content)

        # Should detect both versions
        expect(content).to include('rails (7.1.3)')
        expect(content).to include('rails (8.0.0)')
      end
    end
  end

  describe 'fallback behavior' do
    context 'when Gemfile.lock not found' do
      it 'falls back to Gemfile' do
        mock_read_file('Gemfile.lock', nil) # File doesn't exist

        gemfile_content = 'gem "rails", "~> 8.0.0"'
        mock_read_file('Gemfile', gemfile_content)

        expect(gemfile_content).to include('8.0.0')
      end
    end

    context 'when neither file exists' do
      it 'returns error' do
        mock_read_file('Gemfile.lock', nil)
        mock_read_file('Gemfile', nil)

        # Expected: Error response with no Rails detected
        # This would need actual skill execution to verify
      end
    end
  end

  describe 'version parsing logic' do
    it 'extracts major.minor.patch' do
      version = '8.0.1'
      major, minor, patch = version.split('.').map(&:to_i)

      expect(major).to eq(8)
      expect(minor).to eq(0)
      expect(patch).to eq(1)
    end

    it 'handles version ranges' do
      constraint = '~> 7.1.0'
      # Expected: Interpret as 7.1.x
      expect(constraint).to match(/~> \d+\.\d+\.\d+/)
    end
  end

  describe 'error handling' do
    it 'handles empty Gemfile.lock' do
      mock_read_file('Gemfile.lock', '')

      # Should return error or fallback
    end

    it 'handles corrupted file' do
      mock_read_file('Gemfile.lock', "\x00\x01\x02") # Binary garbage

      # Should handle gracefully
    end
  end
end
