# Test: rails-pattern-finder Skill

## Test 1: Find authentication pattern

**Invoke:** rails-pattern-finder skill
**Query:** "authentication"
**Expected:** Rails 8 authentication generator recommendation

**Steps:**
1. Look up "authentication" in reference.md
2. Should return: Rails 8 uses `rails generate authentication`
3. Link to security.html guide

**Success criteria:** Returns Rails 8 auth generator recommendation

## Test 2: Find background jobs pattern

**Query:** "background jobs"
**Expected:** Rails 8 Solid Queue (built-in)

## Test 3: Find caching pattern

**Query:** "caching"
**Expected:** Rails 8 Solid Cache (built-in)

## Test 4: Find pagination pattern

**Query:** "pagination"
**Expected:** Gem recommendation (pagy or kaminari)
