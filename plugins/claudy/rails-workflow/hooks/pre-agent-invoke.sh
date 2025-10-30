#!/bin/bash
# Pre-agent invocation hook
# Verifies Rails project exists before agents run

set -e

echo "🔍 Verifying Rails project structure..."

# Check for Gemfile
if [ ! -f "Gemfile" ]; then
  echo "❌ Error: No Gemfile found"
  echo "This doesn't appear to be a Rails project"
  exit 1
fi

# Check for Rails gem in Gemfile
if ! grep -q "gem ['\"]rails['\"]" Gemfile; then
  echo "❌ Error: Rails gem not found in Gemfile"
  echo "This doesn't appear to be a Rails project"
  exit 1
fi

# Check for config/application.rb
if [ ! -f "config/application.rb" ]; then
  echo "❌ Error: config/application.rb not found"
  echo "Rails project structure incomplete"
  exit 1
fi

# Check for app/ directory
if [ ! -d "app" ]; then
  echo "❌ Error: app/ directory not found"
  echo "Rails project structure incomplete"
  exit 1
fi

# Detect Rails version
RAILS_VERSION=$(grep "gem ['\"]rails['\"]" Gemfile | grep -oP "[\d\.]+" | head -1)
echo "✅ Rails project detected (version: ${RAILS_VERSION:-unknown})"

# Check for Rails 8 specific features
if [ -f "config/queue.yml" ]; then
  echo "ℹ️  Solid Queue detected (Rails 8+)"
fi

if [ -f "config/cable.yml" ]; then
  echo "ℹ️  Action Cable configured"
fi

echo "✅ Pre-agent checks passed"
exit 0
