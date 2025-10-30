# frozen_string_literal: true

# Mock Claude Code tools for testing skills
module MockTools
  # Mock the Read tool
  def mock_read_file(path, content)
    allow_any_instance_of(Object).to receive(:Read)
      .with(path)
      .and_return(content)
  end

  # Mock the Grep tool
  def mock_grep(pattern, results, path: nil)
    args = [pattern]
    args << { path: path } if path

    allow_any_instance_of(Object).to receive(:Grep)
      .with(*args)
      .and_return(results)
  end

  # Mock the Glob tool
  def mock_glob(pattern, files)
    allow_any_instance_of(Object).to receive(:Glob)
      .with(pattern)
      .and_return(files)
  end

  # Mock the WebFetch tool
  def mock_webfetch(url, prompt, response)
    allow_any_instance_of(Object).to receive(:WebFetch)
      .with(url, prompt)
      .and_return(response)
  end

  # Mock ref_search_documentation MCP tool
  def mock_ref_search(query, results)
    allow_any_instance_of(Object).to receive(:ref_search_documentation)
      .with(query)
      .and_return(results)
  end

  # Mock ref_read_url MCP tool
  def mock_ref_read(url, content)
    allow_any_instance_of(Object).to receive(:ref_read_url)
      .with(url)
      .and_return(content)
  end

  # Simulate Ref MCP not available
  def disable_ref_mcp
    allow_any_instance_of(Object).to receive(:ref_search_documentation)
      .and_raise(NoMethodError, "Ref MCP not available")

    allow_any_instance_of(Object).to receive(:ref_read_url)
      .and_raise(NoMethodError, "Ref MCP not available")
  end

  # Reset all tool mocks
  def reset_tool_mocks
    RSpec::Mocks.space.reset_all
  end
end

RSpec.configure do |config|
  config.include MockTools
end
