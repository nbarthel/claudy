# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe 'Plugin Validation', type: :plugin do
  let(:plugin_root) { File.expand_path('../../plugins/rails-workflow', __dir__) }
  let(:plugin_json_path) { File.join(plugin_root, '.claude-plugin', 'plugin.json') }
  let(:hooks_json_path) { File.join(plugin_root, 'hooks', 'hooks.json') }
  let(:package_json_path) { File.join(plugin_root, 'package.json') }
  let(:readme_path) { File.join(plugin_root, 'README.md') }

  describe 'Plugin Structure' do
    it 'has a .claude-plugin directory' do
      expect(File.directory?(File.join(plugin_root, '.claude-plugin'))).to be true
    end

    it 'has a plugin.json manifest' do
      expect(File.exist?(plugin_json_path)).to be true
    end

    it 'has a README.md' do
      expect(File.exist?(readme_path)).to be true
    end

    it 'has a package.json' do
      expect(File.exist?(package_json_path)).to be true
    end

    it 'has a hooks directory' do
      expect(File.directory?(File.join(plugin_root, 'hooks'))).to be true
    end

    it 'has a commands directory' do
      expect(File.directory?(File.join(plugin_root, 'commands'))).to be true
    end

    it 'has an agents directory' do
      expect(File.directory?(File.join(plugin_root, 'agents'))).to be true
    end
  end

  describe 'plugin.json Validation' do
    let(:plugin_json) { JSON.parse(File.read(plugin_json_path)) }

    it 'is valid JSON' do
      expect { JSON.parse(File.read(plugin_json_path)) }.not_to raise_error
    end

    it 'has required name field' do
      expect(plugin_json).to have_key('name')
      expect(plugin_json['name']).to be_a(String)
      expect(plugin_json['name']).not_to be_empty
    end

    it 'has required description field' do
      expect(plugin_json).to have_key('description')
      expect(plugin_json['description']).to be_a(String)
      expect(plugin_json['description']).not_to be_empty
    end

    it 'has required version field' do
      expect(plugin_json).to have_key('version')
      expect(plugin_json['version']).to be_a(String)
      expect(plugin_json['version']).to match(/^\d+\.\d+\.\d+$/)
    end

    it 'has required author field' do
      expect(plugin_json).to have_key('author')
      expect(plugin_json['author']).to be_a(Hash)
      expect(plugin_json['author']).to have_key('name')
    end

    it 'has keywords array' do
      expect(plugin_json).to have_key('keywords')
      expect(plugin_json['keywords']).to be_an(Array)
      expect(plugin_json['keywords']).not_to be_empty
    end

    it 'uses kebab-case for plugin name' do
      expect(plugin_json['name']).to match(/^[a-z][a-z0-9]*(-[a-z0-9]+)*$/)
    end
  end

  describe 'hooks.json Validation' do
    let(:hooks_json) { JSON.parse(File.read(hooks_json_path)) }

    it 'exists in hooks directory' do
      expect(File.exist?(hooks_json_path)).to be true
    end

    it 'is valid JSON' do
      expect { JSON.parse(File.read(hooks_json_path)) }.not_to raise_error
    end

    it 'has hooks object' do
      expect(hooks_json).to have_key('hooks')
      expect(hooks_json['hooks']).to be_a(Hash)
    end

    context 'Hook Event Structure' do
      let(:valid_events) { %w[PreToolUse PostToolUse UserPromptSubmit SessionStart SessionEnd PreCompact Notification Stop] }

      it 'uses valid hook event names' do
        hooks_json['hooks'].keys.each do |event|
          expect(valid_events).to include(event), "Invalid hook event: #{event}"
        end
      end

      it 'has array values for each event' do
        hooks_json['hooks'].each do |event, value|
          expect(value).to be_an(Array), "Event #{event} should have array value"
        end
      end
    end

    context 'PreToolUse hooks' do
      let(:pre_tool_use_hooks) { hooks_json.dig('hooks', 'PreToolUse') }

      it 'has PreToolUse hooks defined' do
        expect(pre_tool_use_hooks).not_to be_nil
        expect(pre_tool_use_hooks).to be_an(Array)
        expect(pre_tool_use_hooks).not_to be_empty
      end

      it 'follows correct structure' do
        pre_tool_use_hooks.each do |hook_config|
          expect(hook_config).to have_key('hooks')
          expect(hook_config['hooks']).to be_an(Array)
        end
      end

      it 'has command type hooks' do
        pre_tool_use_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            expect(hook).to have_key('type')
            expect(hook['type']).to eq('command')
            expect(hook).to have_key('command')
          end
        end
      end

      it 'uses ${CLAUDE_PLUGIN_ROOT} in command paths' do
        pre_tool_use_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            expect(hook['command']).to include('${CLAUDE_PLUGIN_ROOT}')
          end
        end
      end

      it 'references existing script files' do
        pre_tool_use_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            script_path = hook['command'].gsub('${CLAUDE_PLUGIN_ROOT}', plugin_root)
            expect(File.exist?(script_path)).to be(true), "Script not found: #{script_path}"
          end
        end
      end

      it 'has executable script files' do
        pre_tool_use_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            script_path = hook['command'].gsub('${CLAUDE_PLUGIN_ROOT}', plugin_root)
            expect(File.executable?(script_path)).to be(true), "Script not executable: #{script_path}"
          end
        end
      end
    end

    context 'PostToolUse hooks' do
      let(:post_tool_use_hooks) { hooks_json.dig('hooks', 'PostToolUse') }

      it 'has PostToolUse hooks defined' do
        expect(post_tool_use_hooks).not_to be_nil
        expect(post_tool_use_hooks).to be_an(Array)
      end

      it 'follows correct structure' do
        post_tool_use_hooks.each do |hook_config|
          expect(hook_config).to have_key('hooks')
          expect(hook_config['hooks']).to be_an(Array)
        end
      end

      it 'uses ${CLAUDE_PLUGIN_ROOT} in command paths' do
        post_tool_use_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            expect(hook['command']).to include('${CLAUDE_PLUGIN_ROOT}')
          end
        end
      end
    end

    context 'UserPromptSubmit hooks' do
      let(:user_prompt_hooks) { hooks_json.dig('hooks', 'UserPromptSubmit') }

      it 'has UserPromptSubmit hooks defined' do
        expect(user_prompt_hooks).not_to be_nil
        expect(user_prompt_hooks).to be_an(Array)
      end

      it 'follows correct structure' do
        user_prompt_hooks.each do |hook_config|
          expect(hook_config).to have_key('hooks')
          expect(hook_config['hooks']).to be_an(Array)
        end
      end

      it 'uses ${CLAUDE_PLUGIN_ROOT} in command paths' do
        user_prompt_hooks.each do |hook_config|
          hook_config['hooks'].each do |hook|
            expect(hook['command']).to include('${CLAUDE_PLUGIN_ROOT}')
          end
        end
      end
    end

    context 'Deprecated Fields' do
      it 'does not use deprecated "script" field' do
        hooks_json['hooks'].each do |_event, configs|
          configs.each do |config|
            expect(config).not_to have_key('script'), 'Found deprecated "script" field. Use hooks[].type and hooks[].command instead'
          end
        end
      end

      it 'does not use deprecated "required" field' do
        hooks_json['hooks'].each do |_event, configs|
          configs.each do |config|
            expect(config).not_to have_key('required'), 'Found deprecated "required" field'
          end
        end
      end

      it 'does not use deprecated "timeout_ms" field' do
        hooks_json['hooks'].each do |_event, configs|
          configs.each do |config|
            expect(config).not_to have_key('timeout_ms'), 'Found deprecated "timeout_ms" field'
          end
        end
      end
    end
  end

  describe 'Commands Validation' do
    let(:commands_dir) { File.join(plugin_root, 'commands') }

    it 'has at least one command' do
      commands = Dir.glob(File.join(commands_dir, '*.md'))
      expect(commands).not_to be_empty
    end

    it 'all commands are markdown files' do
      commands = Dir.glob(File.join(commands_dir, '*'))
      commands.each do |cmd|
        next if File.directory?(cmd)

        expect(File.extname(cmd)).to eq('.md')
      end
    end

    it 'all commands have content' do
      commands = Dir.glob(File.join(commands_dir, '*.md'))
      commands.each do |cmd|
        content = File.read(cmd)
        expect(content.strip).not_to be_empty, "Command file #{cmd} is empty"
      end
    end

    it 'commands use kebab-case naming' do
      commands = Dir.glob(File.join(commands_dir, '*.md'))
      commands.each do |cmd|
        basename = File.basename(cmd, '.md')
        expect(basename).to match(/^[a-z][a-z0-9]*(-[a-z0-9]+)*$/), "Command #{basename} should use kebab-case"
      end
    end
  end

  describe 'Agents Validation' do
    let(:agents_dir) { File.join(plugin_root, 'agents') }

    it 'has at least one agent' do
      agents = Dir.glob(File.join(agents_dir, '*.md'))
      expect(agents).not_to be_empty
    end

    it 'all agents are markdown files' do
      agents = Dir.glob(File.join(agents_dir, '*'))
      agents.each do |agent|
        next if File.directory?(agent)

        expect(File.extname(agent)).to eq('.md')
      end
    end

    it 'all agents have content' do
      agents = Dir.glob(File.join(agents_dir, '*.md'))
      agents.each do |agent|
        content = File.read(agent)
        expect(content.strip).not_to be_empty, "Agent file #{agent} is empty"
      end
    end

    it 'agents use kebab-case naming' do
      agents = Dir.glob(File.join(agents_dir, '*.md'))
      agents.each do |agent|
        basename = File.basename(agent, '.md')
        expect(basename).to match(/^[a-z][a-z0-9]*(-[a-z0-9]+)*$/), "Agent #{basename} should use kebab-case"
      end
    end
  end

  describe 'Hook Scripts Validation' do
    let(:hooks_dir) { File.join(plugin_root, 'hooks') }

    it 'all hook scripts are executable' do
      scripts = Dir.glob(File.join(hooks_dir, '*.sh'))
      scripts.each do |script|
        expect(File.executable?(script)).to be(true), "Script #{script} is not executable"
      end
    end

    it 'all hook scripts have shebang' do
      scripts = Dir.glob(File.join(hooks_dir, '*.sh'))
      scripts.each do |script|
        first_line = File.open(script, &:readline).strip
        expect(first_line).to match(/^#!\/.*\/bash$/), "Script #{script} missing proper shebang"
      end
    end

    it 'hook scripts use POSIX-compatible syntax' do
      scripts = Dir.glob(File.join(hooks_dir, '*.sh'))
      scripts.each do |script|
        content = File.read(script)
        # Check for common non-POSIX constructs
        # Match [[ ... ]] bash test construct, but not [[:class:]] POSIX character classes
        expect(content).not_to match(/\[\[\s+.*?\s+\]\]/), "Script #{script} uses [[ ]] test (not POSIX). Use [ ] instead"
        expect(content).not_to match(/^\s*function \w+/), "Script #{script} uses 'function' keyword (not POSIX)"
      end
    end
  end

  describe 'README Validation' do
    let(:readme_content) { File.read(readme_path) }

    it 'has content' do
      expect(readme_content.strip).not_to be_empty
    end

    it 'has a title' do
      expect(readme_content).to match(/^#\s+.+/)
    end

    it 'includes installation instructions' do
      expect(readme_content.downcase).to match(/install/)
    end

    it 'includes usage examples' do
      expect(readme_content.downcase).to match(/usage|example|how to/)
    end
  end

  describe 'package.json Validation' do
    let(:package_json) { JSON.parse(File.read(package_json_path)) }

    it 'is valid JSON' do
      expect { JSON.parse(File.read(package_json_path)) }.not_to raise_error
    end

    it 'has required fields' do
      expect(package_json).to have_key('name')
      expect(package_json).to have_key('version')
      expect(package_json).to have_key('description')
    end

    it 'has valid version format' do
      expect(package_json['version']).to match(/^\d+\.\d+\.\d+$/)
    end
  end
end
