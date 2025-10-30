# Test: rails-api-lookup Skill

## Test 1: Lookup ActiveRecord::Base

**Invoke:** rails-api-lookup skill
**Target:** ActiveRecord::Base
**Expected:** API documentation with methods like find, create, update, destroy

**Steps:**
1. Invoke rails-version-detector → detect Rails version
2. Construct URL: https://api.rubyonrails.org/v{version}/classes/ActiveRecord/Base.html
3. Fetch with WebFetch
4. Verify method signatures returned

**Success criteria:** Returns documentation about ActiveRecord::Base methods

## Test 2: Lookup ActionController::API

**Target:** ActionController::API
**Expected:** API documentation about API-optimized controller

## Test 3: Verify method signature lookup

**Target:** ActiveRecord::Base.create method
**Expected:** Exact method signature with parameters
