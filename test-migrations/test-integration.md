# Test: Integration with Agents

## Test 1: rails-architect uses documentation skills

**Scenario:** User requests "Create a Post model with associations"
**Expected:** Architect invokes rails-docs-search to verify association syntax

**Steps:**
1. User: "Create a Post model with has_many :comments"
2. rails-architect agent invoked
3. Architect should invoke rails-docs-search skill
4. Search for association_basics.html
5. Verify has_many syntax
6. Delegate to rails-model-specialist with verified syntax

**Success criteria:** Model created with correct association syntax from official docs

## Test 2: rails-model-specialist looks up API

**Scenario:** Creating model with has_many :through
**Expected:** Specialist uses rails-api-lookup for ActiveRecord::Associations

**Steps:**
1. Model specialist creating complex association
2. Invokes rails-api-lookup skill
3. Fetches ActiveRecord::Associations::ClassMethods
4. Verifies :through option syntax
5. Implements with exact API signature

**Success criteria:** Association created with correct :through syntax

## Test 3: rails-pattern-finder for authentication

**Scenario:** User requests "Add authentication"
**Expected:** Pattern finder returns Rails 8 authentication generator

**Steps:**
1. User: "I need to add authentication to my Rails 8 app"
2. rails-architect invokes rails-pattern-finder
3. Pattern finder looks up "authentication"
4. Returns: Rails 8 authentication generator
5. Architect provides command: `rails generate authentication`

**Success criteria:** User gets Rails 8-specific authentication recommendation

## Test 4: Version detection integration

**Scenario:** Agents fetch version-specific documentation
**Expected:** All skills use correct Rails version URLs

**Steps:**
1. rails-version-detector invoked first
2. Detects Rails 8.0 from Gemfile.lock
3. Other skills use version in URLs
4. URLs: https://guides.rubyonrails.org/v8.0/...
5. Correct version-specific docs returned

**Success criteria:** All documentation fetches use correct version

## Test 5: Full workflow test

**Scenario:** Complete feature implementation with doc verification

**Steps:**
1. User: "Create a background job for email delivery"
2. rails-architect invoked
3. Architect uses rails-pattern-finder → finds Solid Queue (Rails 8 default)
4. Architect uses rails-docs-search → fetches active_job_basics.html
5. Delegates to rails-service-specialist with pattern
6. Specialist creates job with verified syntax
7. Tests created by rails-test-specialist

**Success criteria:** Complete feature with Rails 8 best practices from official docs
