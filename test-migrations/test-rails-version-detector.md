# Test: rails-version-detector Skill

## Test 1: Detect Rails 8.0

**Invoke:** rails-version-detector skill
**Input:** Gemfile.lock with `    rails (8.0.1)`
**Expected:** Returns "8.0"

**Steps:**
1. Read Gemfile.lock
2. Find line matching `    rails (X.Y.Z)`
3. Parse version number
4. Extract major.minor only

**Success criteria:** Returns "8.0" from "8.0.1"

## Test 2: Detect Rails 7.1

**Input:** Gemfile.lock with `    rails (7.1.3)`
**Expected:** Returns "7.1"

## Test 3: Handle pre-release versions

**Input:** Gemfile.lock with `    rails (8.0.0.beta1)`
**Expected:** Returns "8.0" (strips pre-release tag)

## Test 4: Fallback when no Gemfile.lock

**Input:** No Gemfile.lock found
**Expected:** Returns "8.0" (latest stable) with warning
