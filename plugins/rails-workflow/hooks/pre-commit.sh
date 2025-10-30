#!/bin/bash
# Pre-commit hook
# Security and quality checks before git commits

set -e

echo "🔒 Running pre-commit security checks..."

# Get staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.rb$" || true)

if [ -z "$STAGED_FILES" ]; then
  echo "No Ruby files staged for commit"
  exit 0
fi

echo "Checking staged files..."

# Check for secrets/credentials
echo "Checking for exposed secrets..."
if git diff --cached | grep -iE "(password|secret|api_key|token)[[:space:]]*[:=]" | grep -v "params\.require" | grep -v "#" | grep -v "ENV\["; then
  echo "❌ Error: Potential secrets detected in staged changes"
  echo "Remove sensitive data before committing"
  exit 1
fi

# Check for debugger statements
echo "Checking for debugger statements..."
if echo "$STAGED_FILES" | xargs grep -nE "(binding\.pry|debugger|byebug)" 2>/dev/null | grep -v "#"; then
  echo "❌ Error: Debugger statements detected"
  echo "Remove debugging code before committing"
  exit 1
fi

# Check for strong parameters in controllers
echo "Checking strong parameters..."
CONTROLLER_FILES=$(echo "$STAGED_FILES" | grep "controller" || true)
for file in $CONTROLLER_FILES; do
  if [ -f "$file" ]; then
    # Check if file has create or update actions
    if grep -qE "def (create|update)" "$file"; then
      if ! grep -Eq "params\.require|params\.permit" "$file"; then
        echo "⚠️  Warning: $file has create/update actions but no strong parameters visible"
        echo "Verify strong parameters are properly defined"
      fi
    fi
  fi
done

# Check for SQL injection vulnerabilities
echo "Checking for SQL injection risks..."
if echo "$STAGED_FILES" | xargs grep -nE "\.where\(\".*#\{" 2>/dev/null; then
  echo "❌ Error: String interpolation in SQL detected"
  echo "Use parameterized queries to prevent SQL injection"
  exit 1
fi

# Check for missing migration reversibility
echo "Checking migration reversibility..."
MIGRATION_FILES=$(echo "$STAGED_FILES" | grep "db/migrate" || true)
for file in $MIGRATION_FILES; do
  if [ -f "$file" ]; then
    # Check for dangerous operations without reversible block
    if grep -qE "remove_column|drop_table" "$file"; then
      if ! grep -Eq "reversible do|def down" "$file"; then
        echo "⚠️  Warning: $file has destructive operation without reversible block"
        echo "Add reversible block or down method"
      fi
    fi
  fi
done

echo "✅ Pre-commit checks passed"
exit 0
