---
name: agent-coordination-patterns
description: Optimal multi-agent coordination strategies for the rails-architect
auto_invoke: true
trigger_for: [rails-architect]
tags: [coordination, orchestration, multi-agent, workflow, parallel, sequential]
priority: 1
version: 2.0
---

# Agent Coordination Patterns Skill

Provides optimal coordination strategies for multi-agent Rails workflows.

## What This Skill Does

**For Rails Architect:**
- Parallel vs sequential execution decisions
- Dependency management between agents
- Error recovery across agent handoffs
- State management in multi-agent workflows

**Auto-invokes:** Only for rails-architect agent
**Purpose:** Optimize agent coordination for efficiency

## Coordination Strategies

### 1. Parallel Execution

**When to use:**
- Tasks are independent
- No shared dependencies
- Can execute simultaneously

**Example:**
```
Feature: Blog with posts and comments

Parallel execution:
├── Agent 1: Create Post model
└── Agent 2: Create Comment model

Both can start immediately (independent models)
```

**Pattern:**
```markdown
Task tool invocations:
1. Invoke rails-model-specialist (Post) - don't wait
2. Invoke rails-model-specialist (Comment) - don't wait
3. Wait for both completions
4. Proceed with next phase
```

**Benefits:**
- 2x faster for 2 independent tasks
- Better resource utilization
- Faster user feedback

### 2. Sequential Execution

**When to use:**
- Task B depends on Task A output
- Shared state modification
- Order matters for correctness

**Example:**
```
Feature: API endpoint for posts

Sequential execution:
1. Create Post model (needed by controller)
2. Wait for completion
3. Create PostsController (uses Post model)
4. Wait for completion
5. Create tests (test both model + controller)
```

**Pattern:**
```markdown
Task tool invocations:
1. Invoke rails-model-specialist (Post)
2. Wait for completion
3. Invoke rails-controller-specialist (uses Post)
4. Wait for completion
5. Invoke rails-test-specialist
```

**Benefits:**
- Ensures correct dependency order
- Avoids race conditions
- Clearer error attribution

### 3. Hybrid Execution

**When to use:**
- Mix of dependent and independent tasks
- Optimize for maximum parallelism

**Example:**
```
Feature: Complete e-commerce order flow

Phase 1 (Parallel):
├── Create Order model
├── Create OrderItem model
└── Create Product model (if needed)

Phase 2 (Sequential after Phase 1):
├── Create OrderProcessingService (needs Order, OrderItem, Product)

Phase 3 (Parallel):
├── Create OrdersController
└── Create API serializers

Phase 4 (Sequential):
└── Create comprehensive tests
```

**Pattern:**
```markdown
# Phase 1
parallel_invoke([
  rails-model-specialist(Order),
  rails-model-specialist(OrderItem),
  rails-model-specialist(Product)
])
wait_all()

# Phase 2
invoke(rails-service-specialist(OrderProcessingService))
wait()

# Phase 3
parallel_invoke([
  rails-controller-specialist(OrdersController),
  rails-view-specialist(Serializers)
])
wait_all()

# Phase 4
invoke(rails-test-specialist(ComprehensiveTests))
```

**Benefits:**
- Maximizes parallelism
- Respects dependencies
- Optimal execution time

## Dependency Analysis

### Dependency Types

**1. Model Dependencies:**
```
User model → Post model (belongs_to :user)
Post model → Comment model (has_many :comments)

Order: User → Post → Comment (sequential)
```

**2. Controller Dependencies:**
```
Model exists → Controller can be created
Routes defined → Controller actions valid

Order: Model → Controller (sequential)
```

**3. View Dependencies:**
```
Controller exists → Views can reference actions
Model exists → Views can access attributes

Order: Model + Controller → Views (sequential after both)
```

**4. Test Dependencies:**
```
Implementation exists → Tests can be written

Order: Feature implementation → Tests (sequential)
Exception: TDD approach inverts this (tests first)
```

### Dependency Detection

**Automatic detection:**
```ruby
# Code analysis
class Post < ApplicationRecord
  belongs_to :user  # Depends on User model
end

# Architect detects:
# - User model must exist before Post
# - Sequential: User → Post
```

**Manual specification:**
```markdown
User specifies: "Create Order with OrderItems"

Architect infers:
- OrderItem references Order (foreign key)
- Order must be created first
- Sequential: Order → OrderItem
```

## Error Recovery Patterns

### Pattern 1: Retry with Fix

**Scenario:** Agent fails with correctable error

**Strategy:**
```
1. Agent fails (e.g., missing gem)
2. Analyze error message
3. Apply fix (add gem to Gemfile)
4. Retry same agent
5. Success
```

**Max retries:** 3 per agent

### Pattern 2: Alternative Approach

**Scenario:** Agent fails, different approach needed

**Strategy:**
```
1. Agent fails (e.g., complex service object too ambitious)
2. Analyze failure reason
3. Switch to simpler pattern (extract to concern instead)
4. Invoke different agent or modify parameters
5. Success
```

### Pattern 3: Graceful Degradation

**Scenario:** Agent fails, feature can be partial

**Strategy:**
```
1. Core agent succeeds (Model created)
2. Enhancement agent fails (Serializer generation)
3. Decision: Ship core functionality
4. Log TODO for enhancement
5. Continue with partial implementation
```

## State Management

### Passing Context Between Agents

**Problem:** Agent B needs info from Agent A

**Solution 1: File system state**
```
1. Agent A creates Model file
2. Agent B reads Model file
3. Agent B uses Model info (class name, associations)
```

**Solution 2: Explicit parameter passing**
```
1. Agent A returns: { model_name: "Post", attributes: [...] }
2. Architect stores in context
3. Agent B receives context: create_controller(context[:model_name])
```

### Shared State Conflicts

**Problem:** Two agents modify same file

**Solution: Sequential execution**
```
Scenario: Two agents both need to modify routes.rb

Wrong (parallel):
├── Agent A: adds posts routes
└── Agent B: adds comments routes
Result: Race condition, lost changes

Correct (sequential):
1. Agent A: adds posts routes
2. Wait for completion
3. Agent B: adds comments routes (reads latest routes.rb)
Result: Both changes preserved
```

## Performance Optimization

### Parallelism Limits

**Don't over-parallelize:**
```
Bad: Spawn 10 agents simultaneously
- Resource contention
- Harder to debug
- Diminishing returns

Good: Spawn 2-3 agents per phase
- Manageable
- Clear progress
- Easier error tracking
```

### Execution Time Estimates

**Sequential baseline:**
```
7 agents × 5 min each = 35 min total
```

**With optimal parallelism:**
```
Phase 1: 2 agents parallel = 5 min
Phase 2: 3 agents parallel = 5 min
Phase 3: 2 agents parallel = 5 min
Total: 15 min (2.3x faster)
```

## Configuration

```yaml
# .agent-coordination.yml
execution:
  max_parallel_agents: 3
  retry_limit: 3
  timeout_per_agent: 300  # 5 min

dependencies:
  auto_detect: true
  strict_ordering: false

error_recovery:
  retry_on_failure: true
  alternative_approaches: true
  graceful_degradation: true
```

## References

- **Orchestration Pattern**: Used by rails-architect agent
- **Task Tool**: Native Claude Code multi-agent support
- **Pattern Library**: /patterns/api-patterns.md for feature patterns

---

**This skill helps the architect coordinate agents efficiently for fast, reliable implementations.**
