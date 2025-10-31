# frozen_string_literal: true

# Helper methods for testing Claude Code skills
module SkillTestHelpers
  # Simulate invoking a skill
  # In reality, skills are markdown files that Claude reads and follows
  # For testing, we'll simulate the inputs/outputs
  def invoke_skill(skill_name, params = {})
    skill_path = File.join(
      __dir__, '..', '..', 'plugins', 'rails-workflow', 'skills',
      skill_name, 'SKILL.md'
    )

    raise "Skill not found: #{skill_name}" unless File.exist?(skill_path)

    # Return a mock result structure
    {
      skill: skill_name,
      params: params,
      invoked_at: Time.now,
      status: :pending
    }
  end

  # Load skill content
  def load_skill(skill_name)
    skill_path = File.join(
      __dir__, '..', '..', 'plugins', 'rails-workflow', 'skills',
      skill_name, 'SKILL.md'
    )

    File.read(skill_path) if File.exist?(skill_path)
  end

  # Load reference.md for a skill
  def load_skill_reference(skill_name)
    ref_path = File.join(
      __dir__, '..', '..', 'plugins', 'rails-workflow', 'skills',
      skill_name, 'reference.md'
    )

    File.read(ref_path) if File.exist?(ref_path)
  end

  # Parse skill frontmatter
  def parse_skill_frontmatter(skill_content)
    return {} unless skill_content

    # Extract YAML frontmatter between --- markers
    match = skill_content.match(/^---\s*\n(.*?)\n---\s*\n/m)
    return {} unless match

    require 'yaml'
    YAML.safe_load(match[1])
  rescue StandardError
    {}
  end

  # Setup a mock Rails project environment
  def setup_rails_project(rails_version: '8.0.1', files: {})
    @project_root = Dir.mktmpdir('rails_project_test')

    # Create Gemfile.lock
    gemfile_lock_content = <<~LOCKFILE
      GEM
        remote: https://rubygems.org/
        specs:
          rails (#{rails_version})
    LOCKFILE

    File.write(File.join(@project_root, 'Gemfile.lock'), gemfile_lock_content)

    # Create additional files
    files.each do |path, content|
      full_path = File.join(@project_root, path)
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, content)
    end

    @project_root
  end

  # Cleanup test project
  def cleanup_test_project
    FileUtils.rm_rf(@project_root) if @project_root && Dir.exist?(@project_root)
  end

  # Simulate skill execution result
  def simulate_skill_result(status:, data: {}, error: nil)
    result = {
      status: status,
      timestamp: Time.now.iso8601
    }

    result[:data] = data if data.any?
    result[:error] = error if error

    result
  end
end

RSpec.configure do |config|
  config.include SkillTestHelpers

  # Cleanup after each test
  config.after do
    cleanup_test_project if defined?(@project_root)
  end
end
