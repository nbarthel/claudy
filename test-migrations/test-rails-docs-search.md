# Test: rails-docs-search Skill

## Test 1: Fetch Active Record Basics

**Invoke:** rails-docs-search skill
**Target:** active_record_basics.html
**Expected:** Documentation about creating models, validations

**Steps:**
1. Invoke rails-version-detector → should detect version
2. Construct URL: https://guides.rubyonrails.org/v{version}/active_record_basics.html
3. Fetch with WebFetch
4. Verify content returned

**Success criteria:** Returns content about models

## Test 2: Fetch Routing Guide

**Target:** routing.html
**Expected:** Documentation about RESTful routes

## Test 3: Fetch API App Guide

**Target:** api_app.html
**Expected:** Documentation about ActionController::API
