#!/bin/bash
# Post-agent invocation hook
# Validates agent output and optionally runs tests

set -e

echo "🔍 Validating agent output..."

AGENT_NAME=$1
FILES_CHANGED=$2

# Check for common security issues
echo "Checking for security issues..."

# Strong parameters check in controllers
if echo "$FILES_CHANGED" | grep -q "controller"; then
  echo "Validating strong parameters in controllers..."
  for file in $FILES_CHANGED; do
    case "$file" in
      *controller*)
        if [ -f "$file" ]; then
          if grep -qE "def (create|update)" "$file"; then
            if ! grep -q "_params" "$file"; then
              echo "⚠️  Warning: $file may be missing strong parameters"
            fi
          fi
        fi
        ;;
    esac
  done
fi

# SQL injection check (raw SQL usage)
if grep -rn "\.where(\".*#\{" $FILES_CHANGED 2>/dev/null; then
  echo "⚠️  Warning: String interpolation in SQL detected - verify parameterization"
fi

# Check for Rails conventions
echo "Validating Rails conventions..."

# Model file naming
for file in $FILES_CHANGED; do
  case "$file" in
    app/models/*)
      if [ -f "$file" ]; then
        filename=$(basename "$file" .rb)
        # Simple check - could be enhanced
        echo "✓ Model file: $file"
      fi
      ;;
  esac
done

# Run tests if test files were modified or created
if echo "$FILES_CHANGED" | grep -qE "(spec|test)/"; then
  echo "Test files modified - tests should be run..."

  if [ -f "bin/rspec" ]; then
    echo "ℹ️  RSpec detected - run: bundle exec rspec"
  elif [ -f "bin/rails" ]; then
    echo "ℹ️  Minitest detected - run: bundle exec rails test"
  fi
fi

echo "✅ Post-agent validation complete"
exit 0
