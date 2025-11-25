#!/bin/bash
# Pre-agent invocation hook - Optimized
# Verifies Rails project exists before agents run

set -e

# Combined check: Gemfile exists AND contains rails gem AND has app/ directory
if [ ! -f "Gemfile" ] || [ ! -d "app" ] || ! grep -q "gem ['\"]rails['\"]" Gemfile 2>/dev/null; then
  echo "❌ Not a Rails project (missing Gemfile, app/, or rails gem)"
  exit 1
fi

# Quick version detection from Gemfile.lock (most accurate) or Gemfile
if [ -f "Gemfile.lock" ]; then
  RAILS_VERSION=$(grep -A1 "^    rails " Gemfile.lock 2>/dev/null | head -1 | tr -d ' ' || echo "")
else
  RAILS_VERSION=$(grep "gem ['\"]rails['\"]" Gemfile | sed -n 's/.*[~>= ]*\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -1)
fi

echo "✅ Rails ${RAILS_VERSION:-?} project verified"
exit 0
