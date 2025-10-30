# frozen_string_literal: true

# Helper methods for loading test fixtures
module FixtureHelpers
  # Load a fixture file
  def load_fixture(filename)
    fixture_path = File.join(__dir__, '..', 'fixtures', filename)
    File.read(fixture_path) if File.exist?(fixture_path)
  end

  # Load JSON fixture
  def load_json_fixture(filename)
    content = load_fixture(filename)
    JSON.parse(content) if content
  end

  # Create a Gemfile.lock fixture
  def gemfile_lock_fixture(rails_version:, gems: {})
    content = <<~LOCKFILE
      GEM
        remote: https://rubygems.org/
        specs:
          rails (#{rails_version})
    LOCKFILE

    gems.each do |name, version|
      content << "      #{name} (#{version})\n"
    end

    content
  end

  # Create a reference.md fixture
  def reference_md_fixture(topics: {})
    content = "# Reference\n\n"

    topics.each do |topic_name, topic_data|
      content << "## #{topic_name}\n\n"
      topic_data.each do |key, value|
        content << "- **#{key}**: #{value}\n"
      end
      content << "\n"
    end

    content
  end

  # Rails Guides HTML fixture
  def rails_guide_html_fixture(title:, content:)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{title} — Ruby on Rails Guides</title>
      </head>
      <body>
        <h1>#{title}</h1>
        <div class="content">
          #{content}
        </div>
      </body>
      </html>
    HTML
  end

  # Rails API HTML fixture
  def rails_api_html_fixture(class_name:, methods: [])
    method_html = methods.map do |method|
      <<~METHOD
        <div class="method">
          <h3>#{method[:name]}</h3>
          <p>#{method[:description]}</p>
          <pre>#{method[:signature]}</pre>
        </div>
      METHOD
    end.join("\n")

    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>#{class_name} - Rails API</title>
      </head>
      <body>
        <h1>#{class_name}</h1>
        <div class="methods">
          #{method_html}
        </div>
      </body>
      </html>
    HTML
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
